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
            let hour = calendar.component(.hour, from: now)

            // Load current health first
            let healthData = await catHealth.loadHealth()

            // Trigger at 11 PM OR when health reaches 0
            let isElevenPM = hour == 23
            let isZeroHealth = healthData.health == 0

            guard isElevenPM || isZeroHealth else {
                logger.debug("Summary not triggered (hour: \(hour), health: \(healthData.health))")
                return nil
            }

            // Atomic duplicate prevention using date-based key
            let defaults = UserDefaults.appGroup
            let todayKey = "dailySummaryDate_\(calendar.component(.year, from: now))_\(calendar.component(.dayOfYear, from: now))"

            // Check-and-set atomically
            if defaults.bool(forKey: todayKey) {
                logger.info("Daily summary already generated today (atomic check)")
                return nil
            }

            // Set flag immediately to prevent race conditions
            defaults.set(true, forKey: todayKey)

            // Also verify against existing events (belt-and-suspenders)
            let existingEvents = await userSettings.loadTimelineEvents()
            let todayEvents = existingEvents.filter { Calendar.current.isDateInToday($0.timestamp) }
            let hasDailySummary = todayEvents.contains { $0.trigger == TimelineEntryTrigger.dailySummary.rawValue }

            guard !hasDailySummary else {
                logger.info("Daily summary already exists for today")
                return nil
            }

            let catState = CatState.from(health: healthData.health)

            // Count today's stats
            let bypassCount = todayEvents.filter { $0.eventType == .shieldBypassed }.count

            // Count health band drops by checking actual health transitions
            // (not just events with AI messages, since some may not have been processed yet)
            let healthDropsToday = todayEvents.filter { event in
                // Either already marked as healthBandDrop trigger
                if event.trigger == TimelineEntryTrigger.healthBandDrop.rawValue {
                    return true
                }
                // Or is a bypass that crossed a health band
                if event.eventType == .shieldBypassed {
                    let previousBand = TimelineAIContext.healthBand(event.healthBefore)
                    let currentBand = TimelineAIContext.healthBand(event.healthAfter)
                    return previousBand != currentBand
                }
                return false
            }.count

            let context = TimelineAIContext(
                trigger: .dailySummary,
                tone: CatTone.from(catState: catState),
                currentHealth: healthData.health,
                profile: await userSettings.loadOnboardingProfile(),
                timestamp: now,
                appName: nil,
                healthBefore: nil,
                healthAfter: nil,
                currentHealthBand: TimelineAIContext.healthBand(healthData.health),
                previousHealthBand: 100,
                totalShieldDismissalsToday: bypassCount,
                totalHealthDropsToday: healthDropsToday
            )

            // Load recent AI messages for context
            let recentMessages = await userSettings.loadRecentAIMessages(1)
            guard let result = await timelineAI.generateMessage(context, recentMessages) else {
                logger.warning("AI unavailable for daily summary - no entry created")
                return nil
            }

            // Save to AI message history
            let historyEntry = AIMessageHistory(
                timestamp: now,
                trigger: TimelineEntryTrigger.dailySummary.rawValue,
                healthBand: TimelineAIContext.healthBand(healthData.health),
                response: result.message,
                emoji: result.emoji
            )
            await userSettings.appendAIMessageHistory(historyEntry)

            let summaryEvent = TimelineEvent(
                id: UUID(),
                timestamp: now,
                appName: "Daily Summary",
                healthBefore: healthData.health,
                healthAfter: healthData.health,
                cooldownStarted: now,
                eventType: .aiGenerated,
                aiMessage: result.message,
                aiEmoji: result.emoji,
                trigger: TimelineEntryTrigger.dailySummary.rawValue
            )

            logger.info("Generated daily summary")
            return summaryEvent
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
                currentHealthBand: 100,
                previousHealthBand: 100,
                totalShieldDismissalsToday: 0,
                totalHealthDropsToday: 0
            )

            // Load recent AI messages for context (can include yesterday's for continuity)
            let recentMessages = await userSettings.loadRecentAIMessages(2)
            guard let result = await timelineAI.generateMessage(context, recentMessages) else {
                logger.warning("AI unavailable for daily welcome - no entry created")
                return nil
            }

            // Save to AI message history
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

            logger.info("Generated AI daily welcome")
            return dailyWelcomeEvent
        },
        
        shouldShowAIUnavailableNotice: {
            @Dependency(\.timelineAI) var timelineAI: TimelineAIService
            
            let availability = await timelineAI.checkAvailability()
            
            switch availability {
            case .permanentlyUnavailable:
                let defaults = UserDefaults.appGroup
                let hasShown = defaults.bool(forKey: "hasShownAIUnavailableNotice")
                return !hasShown
            default:
                return false
            }
        },
        
        markAIUnavailableNoticeShown: {
            let defaults = UserDefaults.appGroup
            defaults.set(true, forKey: "hasShownAIUnavailableNotice")
            logger.info("AI unavailable notice marked as shown")
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
