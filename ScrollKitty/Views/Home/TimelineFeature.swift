//
//  TimelineFeature.swift
//  ScrollKitty
//
//  TCA Feature for Timeline with template-based messages
//

import ComposableArchitecture
import Foundation

@Reducer
struct TimelineFeature {

    @ObservableState
    struct State: Equatable {
        var timelineEvents: [TimelineEvent] = []
        var isLoading = false
        var showAIUnavailableNotice = false
        var hasShownAINotice = false
    }
    
    enum Action: Equatable {
        case onAppear
        case loadTimeline
        case timelineLoaded([TimelineEvent])
        case processRawEvents
        case rawEventsProcessed([TimelineEvent])
        case checkForWelcomeMessage
        case welcomeMessageGenerated(TimelineEvent?)
        case checkForDailyWelcome
        case dailyWelcomeGenerated(TimelineEvent?)
        case checkForDailySummary
        case dailySummaryGenerated(TimelineEvent?)
        case checkAIAvailability
        case aiAvailabilityChecked(Bool)
        case dismissAINotice
        case prewarmAI
    }
    
    @Dependency(\.userSettings) var userSettings
    @Dependency(\.timelineManager) var timelineManager
    @Dependency(\.timelineAI) var timelineAI
    @Dependency(\.catHealth) var catHealth
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.checkAIAvailability)
                    await send(.loadTimeline)
                    await send(.checkForDailySummary)
                }
                
            case .prewarmAI:
                // Called by HomeFeature when app becomes active
                return .run { _ in
                    await timelineAI.prewarm()
                }
                
            case .checkAIAvailability:
                return .run { send in
                    let shouldShow = await timelineManager.shouldShowAIUnavailableNotice()
                    await send(.aiAvailabilityChecked(shouldShow))
                }
                
            case .aiAvailabilityChecked(let shouldShow):
                state.showAIUnavailableNotice = shouldShow
                return .none
                
            case .dismissAINotice:
                state.showAIUnavailableNotice = false
                state.hasShownAINotice = true
                return .run { _ in
                    await timelineManager.markAIUnavailableNoticeShown()
                }
                
            case .processRawEvents:
                // Find events without AI messages and generate messages for them
                // Trigger: healthBandDrop only (when crossing 10-point boundaries: 90, 80, 70, etc.)
                return .run { [userSettings, timelineAI, catHealth] send in
                    let events = await userSettings.loadTimelineEvents()
                    let profile = await userSettings.loadOnboardingProfile()

                    // Load recent AI message history for context preservation
                    let recentAIMessages = await userSettings.loadRecentAIMessages(1) // Last 1 day

                    // Sort events chronologically to ensure proper first-bypass detection
                    let sortedEvents = events.sorted { $0.timestamp < $1.timestamp }

                    // Deduplicate events with same health transition within 3-second window
                    let deduplicatedEvents = deduplicateTimelineEvents(sortedEvents)

                    var updatedEvents: [TimelineEvent] = []
                    var hasChanges = false

                    // Count today's stats from ALL events (processed and unprocessed)
                    let todayEvents = deduplicatedEvents.filter { Calendar.current.isDateInToday($0.timestamp) }
                    let todayBypasses = todayEvents.filter { $0.eventType == .shieldBypassed }
                    let totalDismissalsToday = todayBypasses.count

                    // Count health band drops today (only already-processed events)
                    let existingHealthDrops = todayEvents.filter {
                        $0.trigger == TimelineEntryTrigger.healthBandDrop.rawValue &&
                        $0.aiMessage != nil
                    }.count
                    var healthDropsToday = existingHealthDrops

                    for event in deduplicatedEvents {
                        // Skip events that already have AI messages
                        if event.aiMessage != nil {
                            updatedEvents.append(event)
                            continue
                        }

                        // Skip non-bypass events
                        guard event.eventType == .shieldBypassed else {
                            updatedEvents.append(event)
                            continue
                        }

                        // Calculate health bands
                        let previousBand = TimelineAIContext.healthBand(event.healthBefore)
                        let currentBand = TimelineAIContext.healthBand(event.healthAfter)
                        let crossedBand = previousBand != currentBand

                        // Determine trigger - only healthBandDrop matters
                        let trigger: TimelineEntryTrigger?
                        if crossedBand {
                            trigger = .healthBandDrop
                            // Only count drops from today
                            if Calendar.current.isDateInToday(event.timestamp) {
                                healthDropsToday += 1
                            }
                        } else {
                            trigger = nil // No AI for this event
                        }

                        // If no trigger, just keep the event without AI
                        guard let trigger = trigger else {
                            updatedEvents.append(event)
                            continue
                        }

                        // Build context for AI
                        let catState = CatState.from(health: event.healthAfter)
                        let tone = CatTone.from(catState: catState)

                        let context = TimelineAIContext(
                            trigger: trigger,
                            tone: tone,
                            currentHealth: event.healthAfter,
                            profile: profile,
                            timestamp: event.timestamp,
                            appName: event.appName,
                            healthBefore: event.healthBefore,
                            healthAfter: event.healthAfter,
                            currentHealthBand: currentBand,
                            previousHealthBand: previousBand,
                            totalShieldDismissalsToday: totalDismissalsToday,
                            totalHealthDropsToday: healthDropsToday
                        )

                        // Generate template message with recent history for anti-repetition
                        let result = await timelineAI.generateMessage(context, recentAIMessages)

                        // Templates always return - guard for safety only
                        guard let result = result else {
                            updatedEvents.append(event)
                            continue
                        }

                        // Save to AI message history for future context
                        let historyEntry = AIMessageHistory(
                            timestamp: event.timestamp,
                            trigger: trigger.rawValue,
                            healthBand: currentBand,
                            response: result.message,
                            emoji: result.emoji
                        )
                        await userSettings.appendAIMessageHistory(historyEntry)

                        // Create enriched event
                        let enrichedEvent = TimelineEvent(
                            id: event.id,
                            timestamp: event.timestamp,
                            appName: event.appName,
                            healthBefore: event.healthBefore,
                            healthAfter: event.healthAfter,
                            cooldownStarted: event.cooldownStarted,
                            eventType: event.eventType,
                            aiMessage: result.message,
                            aiEmoji: result.emoji,
                            trigger: trigger.rawValue
                        )
                        updatedEvents.append(enrichedEvent)
                        hasChanges = true
                    }

                    // Check if any event reached 0 health (triggers daily summary)
                    let reachedZeroHealth = updatedEvents.contains { $0.healthAfter == 0 }

                    // Save updated events if we made changes
                    if hasChanges {
                        await send(.rawEventsProcessed(updatedEvents))
                    }

                    // Trigger daily summary AFTER events are saved (if health reached 0)
                    if reachedZeroHealth {
                        await send(.checkForDailySummary)
                    }
                }
                
            case .rawEventsProcessed(let updatedEvents):
                // Save all updated events back to UserDefaults atomically, then reload
                return .run { [userSettings] send in
                    await userSettings.saveTimelineEvents(updatedEvents)
                    // Reload timeline to show AI-enriched messages
                    await send(.loadTimeline)
                }
                
            case .loadTimeline:
                state.isLoading = true
                return .run { send in
                    let events = await userSettings.loadTimelineEvents()
                    await send(.timelineLoaded(events))
                }
                
            case .timelineLoaded(let events):
                state.timelineEvents = events
                state.isLoading = false
                return .none
                
            case .checkForWelcomeMessage:
                return .run { send in
                    let welcomeEvent = await timelineManager.getWelcomeMessage()
                    await send(.welcomeMessageGenerated(welcomeEvent))
                }
                
            case .welcomeMessageGenerated(let event):
                if let event = event {
                    return .run { send in
                        await userSettings.appendTimelineEvent(event)
                        await send(.loadTimeline)
                        await send(.checkForDailyWelcome)
                    }
                }
                return .send(.checkForDailyWelcome)

            case .checkForDailyWelcome:
                return .run { send in
                    let dailyWelcomeEvent = await timelineManager.getDailyWelcome()
                    await send(.dailyWelcomeGenerated(dailyWelcomeEvent))
                }

            case .dailyWelcomeGenerated(let event):
                if let event = event {
                    // Save and reload
                    return .run { send in
                        await userSettings.appendTimelineEvent(event)
                        await send(.loadTimeline)
                    }
                }
                return .none

            case .checkForDailySummary:
                return .run { send in
                    let summaryEvent = await timelineManager.checkForDailySummary()
                    await send(.dailySummaryGenerated(summaryEvent))
                }
                
            case .dailySummaryGenerated(let event):
                if let event = event {
                    // Save and reload
                    return .run { send in
                        await userSettings.appendTimelineEvent(event)
                        await send(.loadTimeline)
                    }
                }
                return .none
            }
        }
    }
}

// MARK: - Helpers

/// Deduplicate timeline events with same health transition within 3-second window
private func deduplicateTimelineEvents(_ events: [TimelineEvent]) -> [TimelineEvent] {
    var seen: Set<String> = []
    return events.filter { event in
        // Create key from health transition + rounded timestamp (3-second window)
        let timeWindow = Int(event.timestamp.timeIntervalSince1970 / 3)
        let key = "\(event.healthBefore)-\(event.healthAfter)-\(timeWindow)"
        if seen.contains(key) {
            return false
        }
        seen.insert(key)
        return true
    }
}
