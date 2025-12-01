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
    var processNewEvent: @Sendable (TimelineEvent, CatState) async -> [TimelineEvent]
    var checkForDailySummary: @Sendable () async -> TimelineEvent?
    var getWelcomeMessage: @Sendable () async -> TimelineEvent?
    var shouldShowAIUnavailableNotice: @Sendable () async -> Bool
    var markAIUnavailableNoticeShown: @Sendable () async -> Void
}

// MARK: - Live Implementation

extension TimelineManager {
    static let liveValue = TimelineManager(
        processNewEvent: { event, catState in
            @Dependency(\.userSettings) var userSettings: UserSettingsManager
            @Dependency(\.timelineAI) var timelineAI: TimelineAIService
            
            var newEntries: [TimelineEvent] = []
            
            // Load existing events
            let existingEvents = await userSettings.loadTimelineEvents()
            let todayEvents = existingEvents.filter { Calendar.current.isDateInToday($0.timestamp) }
            
            // Check if we've hit the 8-entry-per-day cap
            let aiGeneratedToday = todayEvents.filter { $0.eventType == .aiGenerated }.count
            if aiGeneratedToday >= 8 {
                print("[TimelineManager] 🚫 Daily AI entry cap reached (8/8)")
                return []
            }
            
            // Detect trigger type
            let triggers = await detectTriggers(
                newEvent: event,
                existingEvents: todayEvents,
                catState: catState
            )
            
            // Generate AI message for each trigger
            for trigger in triggers {
                let context = await buildContext(
                    trigger: trigger,
                    event: event,
                    todayEvents: todayEvents,
                    catState: catState
                )
                
                let result = await timelineAI.generateMessage(context)
                
                let aiEvent = TimelineEvent(
                    id: UUID(),
                    timestamp: Date(),
                    appName: event.appName,
                    healthBefore: event.healthBefore,
                    healthAfter: event.healthAfter,
                    cooldownStarted: event.cooldownStarted,
                    eventType: .aiGenerated,
                    aiMessage: result.message,
                    aiEmoji: result.emoji,
                    trigger: trigger.rawValue,
                    showFallbackNotice: result.showFallbackNotice
                )
                
                newEntries.append(aiEvent)
                print("[TimelineManager] ✨ Generated AI entry for trigger: \(trigger.rawValue)")
            }
            
            return newEntries
        },
        
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
            @Dependency(\.timelineAI) var timelineAI: TimelineAIService
            
            let existingEvents = await userSettings.loadTimelineEvents()
            
            // Only show if timeline is completely empty
            guard existingEvents.isEmpty else { return nil }
            
            let context = TimelineAIContext(
                trigger: .welcomeMessage,
                tone: .playful,
                currentHealth: 100,
                eventCount: 0,
                recentEventWindow: 0,
                timeSinceLastEvent: nil,
                profile: await userSettings.loadOnboardingProfile(),
                appName: nil,
                healthBefore: nil,
                healthAfter: nil
            )
            
            let result = await timelineAI.generateMessage(context)
            
            let welcomeEvent = TimelineEvent(
                id: UUID(),
                timestamp: Date(),
                appName: "Welcome",
                healthBefore: 100,
                healthAfter: 100,
                cooldownStarted: Date(),
                eventType: .aiGenerated,
                aiMessage: result.message,
                aiEmoji: result.emoji,
                trigger: TimelineEntryTrigger.welcomeMessage.rawValue,
                showFallbackNotice: false
            )
            
            print("[TimelineManager] 👋 Generated welcome message")
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
    
    // MARK: - Private Helpers
    
    private static func detectTriggers(
        newEvent: TimelineEvent,
        existingEvents: [TimelineEvent],
        catState: CatState
    ) async -> [TimelineEntryTrigger] {
        var triggers: [TimelineEntryTrigger] = []
        
        // Only process bypassed events for triggers
        guard newEvent.eventType == .shieldBypassed else { return [] }
        
        let bypassEvents = existingEvents.filter { $0.eventType == .shieldBypassed }
        
        // 1. First bypass of day
        if bypassEvents.isEmpty {
            triggers.append(.firstBypassOfDay)
        }
        
        // 2. Cluster detection (3+ bypasses in 15 minutes)
        let fifteenMinutesAgo = Date().addingTimeInterval(-15 * 60)
        let recentBypasses = bypassEvents.filter { $0.timestamp >= fifteenMinutesAgo }
        
        if recentBypasses.count + 1 >= 3 { // +1 for the new event
            // Check if we haven't already logged a cluster recently (prevent spam)
            let hasRecentCluster = existingEvents.contains { event in
                event.trigger == TimelineEntryTrigger.cluster.rawValue &&
                event.timestamp >= fifteenMinutesAgo
            }
            
            if !hasRecentCluster {
                triggers.append(.cluster)
            }
        }
        
        // 3. Quiet return (first event after 4+ hours)
        if let lastBypass = bypassEvents.last {
            let timeSinceLastBypass = Date().timeIntervalSince(lastBypass.timestamp)
            if timeSinceLastBypass >= (4 * 3600) { // 4 hours
                triggers.append(.quietReturn)
            }
        }
        
        // 4. Daily limit reached (narrative only)
        @Dependency(\.userSettings) var userSettings
        if let dailyLimit = await userSettings.loadDailyLimit() {
            let totalMinutesToday = bypassEvents.count * 5 // Rough estimate
            if totalMinutesToday >= dailyLimit {
                let hasLimitEntry = existingEvents.contains { $0.trigger == TimelineEntryTrigger.dailyLimitReached.rawValue }
                if !hasLimitEntry {
                    triggers.append(.dailyLimitReached)
                }
            }
        }
        
        return triggers
    }
    
    private static func buildContext(
        trigger: TimelineEntryTrigger,
        event: TimelineEvent,
        todayEvents: [TimelineEvent],
        catState: CatState
    ) async -> TimelineAIContext {
        @Dependency(\.userSettings) var userSettings
        
        let bypassCount = todayEvents.filter { $0.eventType == .shieldBypassed }.count
        
        // Count recent bypasses (15-min window)
        let fifteenMinutesAgo = Date().addingTimeInterval(-15 * 60)
        let recentBypasses = todayEvents.filter {
            $0.eventType == .shieldBypassed && $0.timestamp >= fifteenMinutesAgo
        }.count
        
        // Calculate time since last event
        var timeSinceLastEvent: TimeInterval? = nil
        if let lastEvent = todayEvents.last {
            timeSinceLastEvent = Date().timeIntervalSince(lastEvent.timestamp)
        }
        
        return TimelineAIContext(
            trigger: trigger,
            tone: CatTone.from(catState: catState),
            currentHealth: event.healthAfter,
            eventCount: bypassCount,
            recentEventWindow: recentBypasses,
            timeSinceLastEvent: timeSinceLastEvent,
            profile: await userSettings.loadOnboardingProfile(),
            appName: event.appName,
            healthBefore: event.healthBefore,
            healthAfter: event.healthAfter
        )
    }
}

// MARK: - Test Implementation

extension TimelineManager {
    static let testValue = TimelineManager(
        processNewEvent: { _, _ in [] },
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
        case .healthy: return .playful
        case .concerned: return .concerned
        case .tired: return .concerned
        case .weak: return .strained
        case .dead: return .faint
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
