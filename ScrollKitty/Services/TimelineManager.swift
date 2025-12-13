//
//  TimelineManager.swift
//  ScrollKitty
//
//  Manages timeline entry triggers, cluster detection, and AI message generation
//

import Foundation
import ComposableArchitecture
import os.log

private let logger = Logger(subsystem: "com.scrollkitty.app", category: "TimelineManager")

// MARK: - TimelineManager (TCA Dependency)

struct TimelineManager: Sendable {
    var checkForDailySummary: @Sendable () async -> TimelineEvent?
    var getWelcomeMessage: @Sendable () async -> TimelineEvent?      // First-ever install only (static)
    var getDailyWelcome: @Sendable () async -> TimelineEvent?        // Daily AI-generated welcome
    var shouldShowAIUnavailableNotice: @Sendable () async -> Bool
    var markAIUnavailableNoticeShown: @Sendable () async -> Void
}

// MARK: - Live Implementation

extension TimelineManager {
    static let liveValue = TimelineManager(
        checkForDailySummary: {
            @Dependency(\.userSettings) var userSettings: UserSettingsManager
            @Dependency(\.timelineAI) var timelineAI: TimelineAIService
            @Dependency(\.catHealth) var catHealth: CatHealthManager

            let now = Date()
            let calendar = Calendar.current

            // 1. Check AI availability
            let availability = await timelineAI.checkAvailability()
            guard case .available = availability else {
                logger.debug("AI unavailable - skipping closing message")
                return nil
            }

            // 2. Check if any closing already generated today
            let todayKey = "closingMessageDate_\(calendar.component(.year, from: now))_\(calendar.component(.dayOfYear, from: now))"
            let defaults = UserDefaults.appGroup
            if defaults.bool(forKey: todayKey) {
                logger.info("Closing message already generated today")
                return nil
            }

            // 3. Load current health
            let healthData = await catHealth.loadHealth()

            // 4. Determine trigger type
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

            // 5. Build context
            let existingEvents = await userSettings.loadTimelineEvents()
            let todayEvents = existingEvents.filter { calendar.isDateInToday($0.timestamp) }

            let bypassCount = todayEvents.filter { $0.eventType == .shieldBypassed }.count
            let healthDropsToday = todayEvents.filter {
                $0.trigger == TimelineEntryTrigger.healthBandDrop.rawValue
            }.count

            // Get daily limit goal
            let dailyLimitMinutes = await userSettings.loadDailyLimit()
            let goalLabel = dailyLimitMinutes.map { "\($0 / 60) hours" }

            // Compute goalMet heuristic
            let (goalMet, goalMetReason) = computeGoalMet(health: healthData.health)

            let context = TerminalNightlyContext(
                trigger: finalTrigger,
                currentHealthBand: TimelineAIContext.healthBand(healthData.health),
                totalShieldDismissalsToday: bypassCount,
                totalHealthDropsToday: healthDropsToday,
                screenTimeGoalLabel: goalLabel,
                goalMet: goalMet,
                goalMetReason: goalMetReason,
                dataCompleteness: .medium
            )

            // 6. Generate AI message
            do {
                let sessionManager = TimelineAISessionManager(systemInstructions: "")
                let message = try await TerminalNightlyAIService.generate(
                    context: context,
                    sessionManager: sessionManager
                )

                // 7. Mark as generated today
                defaults.set(true, forKey: todayKey)

                // 8. Create timeline event
                let event = TimelineEvent(
                    id: UUID(),
                    timestamp: now,
                    appName: finalTrigger == .terminal ? "Terminal" : "Nightly",
                    healthBefore: healthData.health,
                    healthAfter: healthData.health,
                    cooldownStarted: now,
                    eventType: .aiGenerated,
                    aiMessage: message,
                    aiEmoji: nil,
                    trigger: finalTrigger == .terminal ? TimelineEntryTrigger.terminal.rawValue : TimelineEntryTrigger.nightly.rawValue
                )

                logger.info("Generated \(finalTrigger.rawValue) message")
                return event
            } catch {
                logger.error("Failed to generate closing message: \(error.localizedDescription)")
                return nil
            }
        },
        
        getWelcomeMessage: {
            // First-ever install welcome (static message, only once ever)
            let defaults = UserDefaults.appGroup
            let hasSeenFirstWelcome = defaults.bool(forKey: "hasSeenFirstWelcome")

            // Only show if user has NEVER seen the first welcome
            guard !hasSeenFirstWelcome else { return nil }

            // Mark as seen permanently
            defaults.set(true, forKey: "hasSeenFirstWelcome")

            // Static welcome message for first-ever app open
            let welcomeMessage = "We're just starting our journey together. I'll jot little notes here as our day unfolds 😸"

            let welcomeEvent = TimelineEvent(
                id: UUID(),
                timestamp: Date(),
                appName: "Welcome",
                healthBefore: 100,
                healthAfter: 100,
                cooldownStarted: Date(),
                eventType: .aiGenerated,
                aiMessage: welcomeMessage,
                aiEmoji: nil,
                trigger: TimelineEntryTrigger.welcomeMessage.rawValue
            )

            logger.info("First-ever welcome message created")
            return welcomeEvent
        },

        getDailyWelcome: {
            @Dependency(\.userSettings) var userSettings: UserSettingsManager
            @Dependency(\.timelineAI) var timelineAI: TimelineAIService
            @Dependency(\.catHealth) var catHealth: CatHealthManager

            let now = Date()
            let existingEvents = await userSettings.loadTimelineEvents()

            // Skip if welcomeMessage was shown today (first install day)
            let hasWelcomeMessageToday = existingEvents.contains {
                $0.trigger == TimelineEntryTrigger.welcomeMessage.rawValue &&
                Calendar.current.isDateInToday($0.timestamp)
            }
            guard !hasWelcomeMessageToday else {
                logger.info("Welcome message shown today - skipping daily welcome")
                return nil
            }

            // Check if we already have a dailyWelcome for today
            let hasDailyWelcome = existingEvents.contains {
                $0.trigger == TimelineEntryTrigger.dailyWelcome.rawValue &&
                Calendar.current.isDateInToday($0.timestamp)
            }
            guard !hasDailyWelcome else {
                logger.info("Daily welcome already exists for today")
                return nil
            }

            // Load current health (should be 100 after reset, but could vary)
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
                previousHealthBand: currentBand, // Same at start of day
                totalShieldDismissalsToday: 0,
                totalHealthDropsToday: 0
            )

            // Load recent messages for anti-repetition
            let recentMessages = await userSettings.loadRecentAIMessages(2)
            let result = await timelineAI.generateMessage(context, recentMessages)

            // Templates always return a message
            guard let result = result else {
                logger.warning("Template selection failed for daily welcome")
                return nil
            }

            // Save to message history for anti-repetition
            let historyEntry = AIMessageHistory(
                timestamp: now,
                trigger: TimelineEntryTrigger.dailyWelcome.rawValue,
                healthBand: 100,
                response: result.message,
                emoji: result.emoji
            )
            await userSettings.appendAIMessageHistory(historyEntry)

            let dailyWelcomeEvent = TimelineEvent(
                id: UUID(),
                timestamp: now,
                appName: "Daily Welcome",
                healthBefore: healthData.health,
                healthAfter: healthData.health,
                cooldownStarted: now,
                eventType: .aiGenerated,
                aiMessage: result.message,
                aiEmoji: result.emoji,
                trigger: TimelineEntryTrigger.dailyWelcome.rawValue
            )

            logger.info("Generated daily welcome from template")
            return dailyWelcomeEvent
        },
        
        shouldShowAIUnavailableNotice: {
            // Templates always available - no need to show AI unavailable notice
            return false
        },

        markAIUnavailableNoticeShown: {
            // No-op - templates always available
        }
    )

    // MARK: - Helper Functions

    /// Check if current time is within the 11 PM window (22:55-23:05)
    private static func isWithin11PMWindow(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)

        guard let hour = components.hour, let minute = components.minute else {
            return false
        }

        // 22:55-23:05 (10-minute deterministic window)
        if hour == 22 && minute >= 55 {
            return true
        }
        if hour == 23 && minute <= 5 {
            return true
        }
        return false
    }

    /// Compute goalMet heuristic based on health (proxy for actual usage)
    private static func computeGoalMet(health: Int) -> (met: Bool?, reason: String?) {
        if health >= 80 {
            return (true, "stayed strong all day")
        } else if health >= 40 {
            return (nil, nil)  // Inconclusive
        } else {
            return (false, "pushed too far today")
        }
    }
}

// MARK: - Test Implementation

extension TimelineManager {
    static let testValue = TimelineManager(
        checkForDailySummary: { nil },
        getWelcomeMessage: { nil },
        getDailyWelcome: { nil },
        shouldShowAIUnavailableNotice: { false },
        markAIUnavailableNoticeShown: {}
    )
}

// MARK: - CatTone Extension

extension CatTone {
    nonisolated static func from(catState: CatState) -> CatTone {
        switch catState {
        case .healthy: return .playful      // 80-100 HP
        case .concerned: return .concerned  // 60-79 HP
        case .tired: return .strained       // 40-59 HP
        case .weak: return .faint           // 1-39 HP
        case .dead: return .faint           // 0 HP - use faint (AI doesn't recognize "dead" as valid tone)
        }
    }
}

// MARK: - TCA Dependency Registration

extension TimelineManager: DependencyKey {
    // liveValue is already defined in the extension above
}

extension DependencyValues {
    var timelineManager: TimelineManager {
        get { self[TimelineManager.self] }
        set { self[TimelineManager.self] = newValue }
    }
}
