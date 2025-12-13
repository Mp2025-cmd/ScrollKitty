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
            // Daily summary message generation removed - notification still triggers app open
            // but no timeline message is created
            logger.debug("Daily summary check called - message generation disabled")
            return nil
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
