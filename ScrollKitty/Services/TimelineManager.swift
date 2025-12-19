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
            let isIn11PMWindow = isWithin11PMWindow(now)

            let trigger: TerminalNightlyContext.Trigger?
            if isTerminal {
                trigger = .terminal
            } else if isIn11PMWindow {
                trigger = .nightly
            } else {
                logger.debug("Not in trigger window (health: \(healthData.health), hour: \(calendar.component(.hour, from: now)):\(calendar.component(.minute, from: now)))")
                return nil
            }

            guard let finalTrigger = trigger else { return nil }

            defaults.set(true, forKey: todayKey)

            let dailyLimitMinutes = await userSettings.loadDailyLimit()
            let goalLabel = dailyLimitMinutes.map { minutes -> String in
                let hours = Double(minutes) / 60.0
                if hours.truncatingRemainder(dividingBy: 1) == 0 {
                    return "\(Int(hours)) hours"
                } else {
                    return "\(hours) hours"
                }
            }

            let (goalMet, _) = computeGoalMet(health: healthData.health)

            let context = ContextBuilder.make(
                trigger: finalTrigger,
                healthBand: TimelineAIContext.healthBand(healthData.health),
                goalLabel: goalLabel,
                goalMet: goalMet
            )

            // Load recent messages to avoid repetition
            let recentMessages = await userSettings.loadRecentMessages(5)

            // Select template based on trigger type
            let message: String
            if finalTrigger == .terminal {
                message = NightlyTerminalTemplates.selectTerminal(context: context, recentMessages: recentMessages)
            } else {
                message = NightlyTerminalTemplates.selectNightly(context: context, recentMessages: recentMessages)
            }

            // Save to history for anti-repetition
            let historyEntry = MessageHistory(
                timestamp: now,
                trigger: finalTrigger == .terminal ? TimelineEntryTrigger.terminal.rawValue : TimelineEntryTrigger.nightly.rawValue,
                healthBand: healthData.health,
                response: message,
                emoji: nil
            )
            await userSettings.appendMessageHistory(historyEntry)

            let event = TimelineEvent(
                id: UUID(),
                timestamp: now,
                appName: finalTrigger == .terminal ? "Terminal" : "Nightly",
                healthBefore: healthData.health,
                healthAfter: healthData.health,
                cooldownStarted: now,
                eventType: .templateGenerated,
                message: message,
                emoji: nil,
                trigger: finalTrigger == .terminal ? TimelineEntryTrigger.terminal.rawValue : TimelineEntryTrigger.nightly.rawValue
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

    private static func isWithin11PMWindow(_ date: Date) -> Bool {
        #if DEBUG
        if let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app"),
           defaults.bool(forKey: "debug_force11PMWindow") {
            return true
        }
        #endif

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)

        guard let hour = components.hour, let minute = components.minute else {
            return false
        }

        if hour == 22 && minute >= 55 {
            return true
        }
        if hour == 23 && minute <= 5 {
            return true
        }
        return false
    }

    private static func computeGoalMet(health: Int) -> (met: Bool?, reason: String?) {
        if health >= 80 {
            return (true, "stayed strong all day")
        } else if health >= 40 {
            return (nil, nil)
        } else {
            return (false, "pushed too far today")
        }
    }
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
