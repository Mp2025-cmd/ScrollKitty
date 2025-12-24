import Foundation
import ComposableArchitecture
import os.log
private let logger = Logger(subsystem: "com.scrollkitty.app", category: "TimelineManager")

struct TimelineManager: Sendable {
    var checkForDailySummary: @Sendable () async -> TimelineEvent?
    var getWelcomeMessage: @Sendable () async -> TimelineEvent?
    var getDailyWelcome: @Sendable () async -> TimelineEvent?
    var selectTemplateMessage: @Sendable (TimelineAIContext, [MessageHistory]) async -> TimelineMessageResult?
}

extension TimelineManager {
	    static let liveValue = TimelineManager(
	        checkForDailySummary: {
	            @Dependency(\.userSettings) var userSettings: UserSettingsManager
	            @Dependency(\.catHealth) var catHealth: CatHealthManager

            let now = Date()
            let calendar = Calendar.current

            let todayKey = "closingMessageDate_\(calendar.component(.year, from: now))_\(calendar.component(.dayOfYear, from: now))"
            let defaults = UserDefaults.appGroup
            let alreadyGenerated = defaults.bool(forKey: todayKey)
            if alreadyGenerated {
                logger.info("Closing message already generated today")
                return nil
            }

            let healthData = await catHealth.loadHealth()

	            let isTerminal = healthData.health == 0
	            guard isTerminal else {
	                return nil
	            }
	            let finalTrigger: DailySummaryContext.Trigger = .terminal

            defaults.set(true, forKey: todayKey)

            let dailyLimitMinutes = await userSettings.loadDailyLimit()
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"

            let bypassCountToday = defaults.integer(forKey: "bypassCountToday")
            let totalBypassMinutesToday = defaults.integer(forKey: "totalBypassMinutesToday")
            let firstBypass = defaults.object(forKey: "firstBypassTimeToday") as? Date
            let lastBypass = defaults.object(forKey: "lastBypassTimeToday") as? Date

            let context = DailySummaryContext(
                trigger: finalTrigger,
                catHealth: healthData.health,
                healthBand: HealthBasedMessages.band(for: healthData.health),
                dailyLimitMinutes: dailyLimitMinutes,
                bypassCountToday: bypassCountToday,
                totalBypassMinutesToday: totalBypassMinutesToday,
                firstBypassTimeToday: firstBypass.map { timeFormatter.string(from: $0) },
                lastBypassTimeToday: lastBypass.map { timeFormatter.string(from: $0) }
            )

            // Load recent messages to avoid repetition
            let recentMessages = await userSettings.loadRecentMessages(5)

            let message = DailySummaryTemplates.select(context: context, recentMessages: recentMessages)

            // Save to history for anti-repetition
	            let historyEntry = MessageHistory(
	                timestamp: now,
	                trigger: TimelineEntryTrigger.terminal.rawValue,
	                healthBand: healthData.health,
	                response: message,
	                emoji: nil
	            )
            await userSettings.appendMessageHistory(historyEntry)

	            let event = TimelineEvent(
	                id: UUID(),
	                timestamp: now,
	                appName: "Terminal",
	                healthBefore: healthData.health,
	                healthAfter: healthData.health,
	                cooldownStarted: now,
	                eventType: .templateGenerated,
	                message: message,
	                emoji: nil,
	                trigger: TimelineEntryTrigger.terminal.rawValue
	            )

            logger.info("Generated \(finalTrigger.rawValue) message: \(message)")
            return event
        },
        
        getWelcomeMessage: {
            let defaults = UserDefaults.appGroup
            let hasSeenFirstWelcome = defaults.bool(forKey: "hasSeenFirstWelcome")

            guard !hasSeenFirstWelcome else { return nil }

            defaults.set(true, forKey: "hasSeenFirstWelcome")

            let welcomeMessage = "We're just starting our journey together. I'll jot little notes here as our day unfolds 😸"

            let welcomeEvent = TimelineEvent(
                id: UUID(),
                timestamp: Date(),
                appName: "Welcome",
                healthBefore: 100,
                healthAfter: 100,
                cooldownStarted: Date(),
                eventType: .templateGenerated,
                message: welcomeMessage,
                emoji: nil,
                trigger: TimelineEntryTrigger.welcomeMessage.rawValue
            )

            logger.info("First-ever welcome message created")
            return welcomeEvent
        },

        getDailyWelcome: {
            @Dependency(\.userSettings) var userSettings: UserSettingsManager
            @Dependency(\.catHealth) var catHealth: CatHealthManager

            let now = Date()
            let existingEvents = await userSettings.loadTimelineEvents()

            let hasWelcomeMessageToday = existingEvents.contains {
                $0.trigger == TimelineEntryTrigger.welcomeMessage.rawValue &&
                Calendar.current.isDateInToday($0.timestamp)
            }
            guard !hasWelcomeMessageToday else {
                logger.info("Welcome message shown today - skipping daily welcome")
                return nil
            }

            let hasDailyWelcome = existingEvents.contains {
                $0.trigger == TimelineEntryTrigger.dailyWelcome.rawValue &&
                Calendar.current.isDateInToday($0.timestamp)
            }
            guard !hasDailyWelcome else {
                logger.info("Daily welcome already exists for today")
                return nil
            }

            let healthData = await catHealth.loadHealth()
            let currentBand = TimelineAIContext.healthBand(healthData.health)
            let catState = CatState.from(health: healthData.health)

            let context = TimelineAIContext(
                trigger: .dailyWelcome,
                tone: CatTone.from(catState: catState),
                currentHealth: healthData.health,
                profile: await userSettings.loadOnboardingProfile(),
                timestamp: now,
                appName: nil,
                healthBefore: nil,
                healthAfter: nil,
                currentHealthBand: currentBand,
                previousHealthBand: currentBand,
                totalShieldDismissalsToday: 0,
                totalHealthDropsToday: 0
            )

            let recentMessages = await userSettings.loadRecentMessages(2)
            
            // Select template message directly
            let message = TimelineTemplateMessages.selectMessage(
                forHealthBand: context.currentHealthBand,
                trigger: context.trigger,
                avoiding: recentMessages
            )
            let result = TimelineMessageResult(message: message, emoji: nil)

            let historyEntry = MessageHistory(
                timestamp: now,
                trigger: TimelineEntryTrigger.dailyWelcome.rawValue,
                healthBand: 100,
                response: result.message,
                emoji: result.emoji
            )
            await userSettings.appendMessageHistory(historyEntry)

            let dailyWelcomeEvent = TimelineEvent(
                id: UUID(),
                timestamp: now,
                appName: "Daily Welcome",
                healthBefore: healthData.health,
                healthAfter: healthData.health,
                cooldownStarted: now,
                eventType: .templateGenerated,
                message: result.message,
                emoji: result.emoji,
                trigger: TimelineEntryTrigger.dailyWelcome.rawValue
            )

            logger.info("Generated daily welcome from template")
            return dailyWelcomeEvent
        },
        
        selectTemplateMessage: { context, recentMessages in
            // Select template message based on health band and trigger
            let message = TimelineTemplateMessages.selectMessage(
                forHealthBand: context.currentHealthBand,
                trigger: context.trigger,
                avoiding: recentMessages
            )
            return TimelineMessageResult(message: message, emoji: nil)
        }
	    )
}

extension TimelineManager {
    static let testValue = TimelineManager(
        checkForDailySummary: { nil },
        getWelcomeMessage: { nil },
        getDailyWelcome: { nil },
        selectTemplateMessage: { context, _ in
            let message = TimelineTemplateMessages.selectMessage(
                forHealthBand: context.currentHealthBand,
                trigger: context.trigger,
                avoiding: []
            )
            return TimelineMessageResult(message: message, emoji: nil)
        }
    )

}

extension CatTone {
    nonisolated static func from(catState: CatState) -> CatTone {
        switch catState {
        case .healthy: return .playful
        case .concerned: return .concerned
        case .tired: return .strained
        case .weak: return .faint
        case .dead: return .faint
        }
    }
}

extension TimelineManager: DependencyKey {}

extension DependencyValues {
    var timelineManager: TimelineManager {
        get { self[TimelineManager.self] }
        set { self[TimelineManager.self] = newValue }
    }
}
