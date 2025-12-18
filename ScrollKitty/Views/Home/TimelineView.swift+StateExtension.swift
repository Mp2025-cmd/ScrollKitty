import Foundation
import ComposableArchitecture

private struct TodayStats {
    let totalDismissals: Int
    let existingHealthDrops: Int
}

extension TimelineFeature.State {
    static func formattedDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    static func formattedDayOfWeek(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    

    /// Process timeline events and add template messages for health band drops
    /// Only generates messages when health crosses 10-point boundaries (90→80, 80→70, etc.)
    func processRawEvents() -> EffectOf<TimelineFeature> {
        .run { send in
            @Dependency(\.userSettings) var userSettings
            @Dependency(\.timelineManager) var timelineManager
            @Dependency(\.calendar) var calendar

            let events = await userSettings.loadTimelineEvents()
            let profile = await userSettings.loadOnboardingProfile()
            let recentMessages = await userSettings.loadRecentMessages(1)
            guard let profile else {
                return
            }
            let sortedEvents = events.sorted { $0.timestamp < $1.timestamp }
            let deduplicatedEvents = self.deduplicateTimelineEvents(sortedEvents)
            let todayStats = self.calculateTodayStats(deduplicatedEvents, calendar: calendar)

            let (updatedEvents, hasChanges) = await self.enrichEventsWithTemplateMessages(
                events: deduplicatedEvents,
                profile: profile,
                recentMessages: recentMessages ?? [],
                todayStats: todayStats,
                calendar: calendar,
                timelineManager: timelineManager,
                userSettings: userSettings
            )

            if hasChanges {
                await send(.rawEventsProcessed(updatedEvents))
            }

            if updatedEvents.contains(where: { $0.healthAfter == 0 }) {
                await send(.checkForDailySummary)
            }
        }
    }
    
    private func calculateTodayStats(_ events: [TimelineEvent], calendar: Calendar) -> TodayStats {
        let todayEvents = events.filter { calendar.isDateInToday($0.timestamp) }
        let todayBypasses = todayEvents.filter { $0.eventType == .shieldBypassed }
        let existingHealthDrops = todayEvents.filter {
            $0.trigger == TimelineEntryTrigger.healthBandDrop.rawValue && $0.message != nil
        }
        
        return TodayStats(
            totalDismissals: todayBypasses.count,
            existingHealthDrops: existingHealthDrops.count
        )
    }
    
    /// Enrich timeline events with template messages for health band drops
    private func enrichEventsWithTemplateMessages(
        events: [TimelineEvent],
        profile: UserOnboardingProfile,
        recentMessages: [MessageHistory],
        todayStats: TodayStats,
        calendar: Calendar,
        timelineManager: TimelineManager,
        userSettings: UserSettingsManager
    ) async -> ([TimelineEvent], Bool) {
        var updatedEvents: [TimelineEvent] = []
        var hasChanges = false
        var healthDropsToday = todayStats.existingHealthDrops

        for event in events {
            // Skip events that already have messages or aren't bypasses
            guard event.message == nil, event.eventType == .shieldBypassed else {
                updatedEvents.append(event)
                continue
            }

            let previousBand = TimelineAIContext.healthBand(event.healthBefore)
            let currentBand = TimelineAIContext.healthBand(event.healthAfter)

            // Only generate messages when health band changes (crosses 10-point boundary)
            guard previousBand != currentBand else {
                updatedEvents.append(event)
                continue
            }

            if calendar.isDateInToday(event.timestamp) {
                healthDropsToday += 1
            }

            let enrichedEvent = await self.generateTemplateMessageForEvent(
                event,
                profile: profile,
                recentMessages: recentMessages,
                previousBand: previousBand,
                currentBand: currentBand,
                totalDismissals: todayStats.totalDismissals,
                healthDropsToday: healthDropsToday,
                timelineManager: timelineManager,
                userSettings: userSettings
            )

            updatedEvents.append(enrichedEvent)
            hasChanges = true
        }

        return (updatedEvents, hasChanges)
    }
    
    /// Select and attach a template message for a health band drop event
    private func generateTemplateMessageForEvent(
        _ event: TimelineEvent,
        profile: UserOnboardingProfile,
        recentMessages: [MessageHistory],
        previousBand: Int,
        currentBand: Int,
        totalDismissals: Int,
        healthDropsToday: Int,
        timelineManager: TimelineManager,
        userSettings: UserSettingsManager
    ) async -> TimelineEvent {
        let catState = CatState.from(health: event.healthAfter)
        let tone = CatTone.from(catState: catState)

        let context = TimelineAIContext(
            trigger: .healthBandDrop,
            tone: tone,
            currentHealth: event.healthAfter,
            profile: profile,
            timestamp: event.timestamp,
            appName: event.appName,
            healthBefore: event.healthBefore,
            healthAfter: event.healthAfter,
            currentHealthBand: currentBand,
            previousHealthBand: previousBand,
            totalShieldDismissalsToday: totalDismissals,
            totalHealthDropsToday: healthDropsToday
        )

        guard let result = await timelineManager.selectTemplateMessage(context, recentMessages) else {
            return event
        }

        // Save to message history for anti-repetition
        let historyEntry = MessageHistory(
            timestamp: event.timestamp,
            trigger: TimelineEntryTrigger.healthBandDrop.rawValue,
            healthBand: currentBand,
            response: result.message,
            emoji: result.emoji
        )
        await userSettings.appendMessageHistory(historyEntry)

        return TimelineEvent(
            id: event.id,
            timestamp: event.timestamp,
            appName: event.appName,
            healthBefore: event.healthBefore,
            healthAfter: event.healthAfter,
            cooldownStarted: event.cooldownStarted,
            eventType: event.eventType,
            message: result.message,
            emoji: result.emoji,
            trigger: TimelineEntryTrigger.healthBandDrop.rawValue
        )
    }
    
    private func deduplicateTimelineEvents(_ events: [TimelineEvent]) -> [TimelineEvent] {
        var seen: Set<String> = []
        return events.filter { event in
            let timeWindow = Int(event.timestamp.timeIntervalSince1970 / 3)
            let key = "\(event.healthBefore)-\(event.healthAfter)-\(timeWindow)"
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }
    }
}
