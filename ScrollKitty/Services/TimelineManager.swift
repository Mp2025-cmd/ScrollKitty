//
//  TimelineManager.swift
//  ScrollKitty
//
//  Manages timeline entry triggers, cluster detection, and AI message generation
//

import Foundation
import ComposableArchitecture

// MARK: - TimelineManager (TCA Dependency)

struct TimelineManager: Sendable {
    var checkForDailySummary: @Sendable () async -> TimelineEvent?
    var getWelcomeMessage: @Sendable () async -> TimelineEvent?
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
            
            // Only generate between 9-10 PM
            guard hour >= 21 && hour < 22 else { return nil }
            
            // Check if we already have a daily summary for today
            let existingEvents = await userSettings.loadTimelineEvents()
            let todayEvents = existingEvents.filter { Calendar.current.isDateInToday($0.timestamp) }
            let hasDailySummary = todayEvents.contains { $0.trigger == TimelineEntryTrigger.dailySummary.rawValue }
            
            guard !hasDailySummary else {
                print("[TimelineManager] ℹ️ Daily summary already exists for today")
                return nil
            }
            
            // Check 8-entry cap
            let aiGeneratedToday = todayEvents.filter { $0.eventType == .aiGenerated }.count
            guard aiGeneratedToday < 8 else {
                print("[TimelineManager] 🚫 Daily AI entry cap reached, skipping summary")
                return nil
            }
            
            // Load current health
            let healthData = await catHealth.loadHealth()
            let catState = CatState.from(health: healthData.health)
            
            // Count today's bypasses
            let bypassCount = todayEvents.filter { $0.eventType == .shieldBypassed }.count
            
            let context = TimelineAIContext(
                trigger: .dailySummary,
                tone: CatTone.from(catState: catState),
                currentHealth: healthData.health,
                eventCount: bypassCount,
                recentEventWindow: 0,
                timeSinceLastEvent: nil,
                profile: await userSettings.loadOnboardingProfile(),
                timestamp: now,  // For time-of-day context
                appName: nil,
                healthBefore: nil,
                healthAfter: nil
            )
            
            let result = await timelineAI.generateMessage(context)
            
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
                trigger: TimelineEntryTrigger.dailySummary.rawValue,
                showFallbackNotice: result.showFallbackNotice
            )
            
            print("[TimelineManager] 🌙 Generated daily summary")
            return summaryEvent
        },
        
        getWelcomeMessage: {
            @Dependency(\.userSettings) var userSettings: UserSettingsManager
            
            let existingEvents = await userSettings.loadTimelineEvents()
            
            // Only show if timeline is completely empty
            guard existingEvents.isEmpty else { return nil }
            
            // Always use the pre-written welcome message (never AI-generated)
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
                trigger: TimelineEntryTrigger.welcomeMessage.rawValue,
                showFallbackNotice: false
            )
            
            print("[TimelineManager] 👋 Welcome message created")
            return welcomeEvent
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
            print("[TimelineManager] ℹ️ AI unavailable notice marked as shown")
        }
    )
}

// MARK: - Test Implementation

extension TimelineManager {
    static let testValue = TimelineManager(
        checkForDailySummary: { nil },
        getWelcomeMessage: { nil },
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
