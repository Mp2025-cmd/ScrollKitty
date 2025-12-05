//
//  TimelineFeature.swift
//  ScrollKitty
//
//  TCA Feature for Timeline with AI-powered messages
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
                // Raw events are processed by HomeFeature.appBecameActive
                // Here we just load and display + check for welcome/summary
                return .run { send in
                    await send(.checkAIAvailability)
                    await send(.loadTimeline)
                    await send(.checkForWelcomeMessage)
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
                return .run { [userSettings, timelineAI, catHealth] send in
                    let events = await userSettings.loadTimelineEvents()
                    let healthData = await catHealth.loadHealth()
                    let profile = await userSettings.loadOnboardingProfile()
                    
                    var updatedEvents: [TimelineEvent] = []
                    var hasChanges = false
                    
                    // Get events that already have AI messages (for trigger detection)
                    let processedEvents = events.filter { $0.aiMessage != nil }
                    let processedBypassCount = processedEvents.filter { $0.eventType == .shieldBypassed || $0.trigger == "firstBypassOfDay" }.count
                    
                    for event in events {
                        // Skip events that already have AI messages
                        if event.aiMessage != nil {
                            updatedEvents.append(event)
                            continue
                        }
                        
                        // Skip non-bypass events (only generate AI for bypasses)
                        guard event.eventType == .shieldBypassed else {
                            updatedEvents.append(event)
                            continue
                        }
                        
                        // Determine trigger type
                        let trigger: TimelineEntryTrigger
                        if processedBypassCount == 0 {
                            trigger = .firstBypassOfDay
                        } else {
                            // For subsequent bypasses, just use a generic bypass trigger
                            // (cluster detection, etc. would need more complex logic)
                            trigger = .firstBypassOfDay // Reuse for now - generates appropriate message
                        }
                        
                        // Build context for AI
                        let catState = CatState.from(health: event.healthAfter)
                        let tone = CatTone.from(catState: catState)
                        
                        let context = TimelineAIContext(
                            trigger: trigger,
                            tone: tone,
                            currentHealth: event.healthAfter,
                            eventCount: processedBypassCount + 1,
                            recentEventWindow: 0,
                            timeSinceLastEvent: nil,
                            profile: profile,
                            timestamp: event.timestamp,  // For time-of-day context
                            appName: nil,  // Don't send app name to AI
                            healthBefore: event.healthBefore,
                            healthAfter: event.healthAfter
                        )
                        
                        // Generate AI message
                        let result = await timelineAI.generateMessage(context)
                        
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
                            trigger: trigger.rawValue,
                            showFallbackNotice: result.showFallbackNotice
                        )
                        updatedEvents.append(enrichedEvent)
                        hasChanges = true
                        print("[TimelineFeature] ✨ Generated AI message for event: \(event.id)")
                    }
                    
                    // Save updated events if we made changes
                    if hasChanges {
                        await send(.rawEventsProcessed(updatedEvents))
                    }
                }
                
            case .rawEventsProcessed(let updatedEvents):
                // Save all updated events back to UserDefaults, then reload
                return .run { [userSettings] send in
                    await userSettings.clearTimelineEvents()
                    for event in updatedEvents {
                        await userSettings.appendTimelineEvent(event)
                    }
                    print("[TimelineFeature] 💾 Saved \(updatedEvents.count) events with AI messages")
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
