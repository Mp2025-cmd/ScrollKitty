import Foundation
@preconcurrency import FamilyControls
import ComposableArchitecture

// MARK: - Timeline Event Model

public struct TimelineEvent: Codable, Equatable, Sendable {
    let id: UUID
    let timestamp: Date
    let appName: String // Display name for timeline
    let healthBefore: Int
    let healthAfter: Int
    let cooldownStarted: Date
    let eventType: EventType

    // AI-generated message fields
    let aiMessage: String?
    let aiEmoji: String?
    let trigger: String? // TimelineEntryTrigger.rawValue
    
    enum EventType: String, Codable, Sendable {
        case shieldShown
        case shieldBypassed
        case aiGenerated // For AI-only entries (daily summary, welcome, etc.)
    }
    
    init(
        id: UUID = UUID(),
        timestamp: Date,
        appName: String,
        healthBefore: Int,
        healthAfter: Int,
        cooldownStarted: Date,
        eventType: EventType,
        aiMessage: String? = nil,
        aiEmoji: String? = nil,
        trigger: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.appName = appName
        self.healthBefore = healthBefore
        self.healthAfter = healthAfter
        self.cooldownStarted = cooldownStarted
        self.eventType = eventType
        self.aiMessage = aiMessage
        self.aiEmoji = aiEmoji
        self.trigger = trigger
    }
}

// MARK: - UserSettingsManager (TCA Dependency)

public struct UserSettingsManager: Sendable {
    // App Selection
    nonisolated(unsafe) var saveSelectedApps: @Sendable (FamilyActivitySelection) async -> Void
    nonisolated(unsafe) var loadSelectedApps: @Sendable () async -> FamilyActivitySelection?
    
    // Daily Limit (narrative only)
    var saveDailyLimit: @Sendable (Int) async -> Void
    var loadDailyLimit: @Sendable () async -> Int?
    
    // Shield Interval (cooldown duration)
    var saveShieldInterval: @Sendable (Int) async -> Void
    var loadShieldInterval: @Sendable () async -> Int?
    
    // Focus Window
    var saveFocusWindow: @Sendable (FocusWindowData) async -> Void
    var loadFocusWindow: @Sendable () async -> FocusWindowData?
    
    // Global Cat Health (0-100)
    var saveGlobalHealth: @Sendable (Int) async -> Void
    var loadGlobalHealth: @Sendable () async -> Int
    var initializeHealth: @Sendable () async -> Void
    
    // Global Cooldown
    var saveCooldownEnd: @Sendable (Date) async -> Void
    var loadCooldownEnd: @Sendable () async -> Date?
    var clearCooldown: @Sendable () async -> Void
    
    // Timeline Events
    var appendTimelineEvent: @Sendable (TimelineEvent) async -> Void
    var loadTimelineEvents: @Sendable () async -> [TimelineEvent]
    var clearTimelineEvents: @Sendable () async -> Void
    var saveTimelineEvents: @Sendable ([TimelineEvent]) async -> Void
    
    // Onboarding Profile (for AI tone tuning)
    var saveOnboardingProfile: @Sendable (UserOnboardingProfile) async -> Void
    var loadOnboardingProfile: @Sendable () async -> UserOnboardingProfile?

    // AI Message History (for context preservation)
    var appendAIMessageHistory: @Sendable (AIMessageHistory) async -> Void
    var loadAIMessageHistory: @Sendable () async -> [AIMessageHistory]
    var loadRecentAIMessages: @Sendable (Int) async -> [AIMessageHistory]  // Days back

    // Legacy (for migration)
    var getTodayTotal: @Sendable () async -> Double
}

// MARK: - Dependency Key

extension UserSettingsManager: DependencyKey {
  public  static let liveValue: UserSettingsManager = {
        let appGroupID = "group.com.scrollkitty.app"
        
        nonisolated(unsafe) let saveApps: @Sendable (FamilyActivitySelection) async -> Void = { selection in
            let defaults = UserDefaults(suiteName: appGroupID)
            if let encoded = try? JSONEncoder().encode(selection) {
                defaults?.set(encoded, forKey: "selectedApps")
            }
        }

        nonisolated(unsafe) let loadApps: @Sendable () async -> FamilyActivitySelection? = {
            let defaults = UserDefaults(suiteName: appGroupID)
            guard let data = defaults?.data(forKey: "selectedApps"),
                  let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
                return nil
            }
            return decoded
        }
        
        return Self(
            saveSelectedApps: saveApps,
            loadSelectedApps: loadApps,
            
            // Daily Limit (narrative only, no game logic)
            saveDailyLimit: { minutes in
                let defaults = UserDefaults(suiteName: appGroupID)
                defaults?.set(minutes, forKey: "dailyLimit")
            },
            loadDailyLimit: {
                let defaults = UserDefaults(suiteName: appGroupID)
                let limit = defaults?.integer(forKey: "dailyLimit") ?? 0
                return limit > 0 ? limit : nil
            },
            
            // Shield Interval (default: 20 minutes)
            saveShieldInterval: { minutes in
                let defaults = UserDefaults(suiteName: appGroupID)
                defaults?.set(minutes, forKey: "shieldInterval")
            },
            loadShieldInterval: {
                let defaults = UserDefaults(suiteName: appGroupID)
                let interval = defaults?.integer(forKey: "shieldInterval") ?? 0
                return interval > 0 ? interval : 20 // Default to 20 minutes
            },
            
            // Focus Window
            saveFocusWindow: { data in
                let defaults = UserDefaults(suiteName: appGroupID)
                if let encoded = try? JSONEncoder().encode(data) {
                    defaults?.set(encoded, forKey: "focusWindow")
                }
            },
            loadFocusWindow: {
                let defaults = UserDefaults(suiteName: appGroupID)
                guard let data = defaults?.data(forKey: "focusWindow"),
                      let decoded = try? JSONDecoder().decode(FocusWindowData.self, from: data) else {
                    return nil
                }
                return decoded
            },
            
            // Global Cat Health
            saveGlobalHealth: { health in
                let defaults = UserDefaults(suiteName: appGroupID)
                let clamped = max(0, min(100, health))
                defaults?.set(clamped, forKey: "catHealth")
            },
            loadGlobalHealth: {
                let defaults = UserDefaults(suiteName: appGroupID)
                let health = defaults?.integer(forKey: "catHealth") ?? 100
                // If never set (0), return 100
                return health > 0 ? health : 100
            },
            initializeHealth: {
                let defaults = UserDefaults(suiteName: appGroupID)
                defaults?.set(100, forKey: "catHealth")
                // Set lastResetDate so midnight reset logic works correctly on subsequent days
                defaults?.set(Date(), forKey: "lastResetDate")
            },
            
            // Global Cooldown
            saveCooldownEnd: { date in
                let defaults = UserDefaults(suiteName: appGroupID)
                defaults?.set(date.timeIntervalSince1970, forKey: "cooldownEnd")
            },
            loadCooldownEnd: {
                let defaults = UserDefaults(suiteName: appGroupID)
                let timestamp = defaults?.double(forKey: "cooldownEnd") ?? 0
                guard timestamp > 0 else { return nil }
                return Date(timeIntervalSince1970: timestamp)
            },
            clearCooldown: {
                let defaults = UserDefaults(suiteName: appGroupID)
                defaults?.removeObject(forKey: "cooldownEnd")
            },
            
            // Timeline Events
            appendTimelineEvent: { event in
                let defaults = UserDefaults(suiteName: appGroupID)
                var events = loadTimelineEventsSync(defaults: defaults)
                events.append(event)
                // Keep only last 100 events
                if events.count > 100 {
                    events = Array(events.suffix(100))
                }
                if let encoded = try? JSONEncoder().encode(events) {
                    defaults?.set(encoded, forKey: "timelineEvents")
                }
            },
            loadTimelineEvents: {
                let defaults = UserDefaults(suiteName: appGroupID)
                return loadTimelineEventsSync(defaults: defaults)
            },
            clearTimelineEvents: {
                let defaults = UserDefaults(suiteName: appGroupID)
                defaults?.removeObject(forKey: "timelineEvents")
            },
            saveTimelineEvents: { events in
                let defaults = UserDefaults(suiteName: appGroupID)
                // Keep only last 100 events
                let eventsToSave = events.count > 100 ? Array(events.suffix(100)) : events
                if let encoded = try? JSONEncoder().encode(eventsToSave) {
                    defaults?.set(encoded, forKey: "timelineEvents")
                }
            },
            
            // Onboarding Profile
            saveOnboardingProfile: { profile in
                let defaults = UserDefaults(suiteName: appGroupID)
                if let encoded = try? JSONEncoder().encode(profile) {
                    defaults?.set(encoded, forKey: "onboardingProfile")
                }
            },
            loadOnboardingProfile: {
                let defaults = UserDefaults(suiteName: appGroupID)
                guard let data = defaults?.data(forKey: "onboardingProfile"),
                      let decoded = try? JSONDecoder().decode(UserOnboardingProfile.self, from: data) else {
                    return nil
                }
                return decoded
            },

            // AI Message History
            appendAIMessageHistory: { message in
                let defaults = UserDefaults(suiteName: appGroupID)
                var history = loadAIMessageHistorySync(defaults: defaults)
                history.append(message)

                // Prune to last 30 days
                let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
                history = history.filter { $0.timestamp > cutoff }

                if let encoded = try? JSONEncoder().encode(history) {
                    defaults?.set(encoded, forKey: "aiMessageHistory")
                }
            },
            loadAIMessageHistory: {
                let defaults = UserDefaults(suiteName: appGroupID)
                return loadAIMessageHistorySync(defaults: defaults)
            },
            loadRecentAIMessages: { daysBack in
                let defaults = UserDefaults(suiteName: appGroupID)
                let history = loadAIMessageHistorySync(defaults: defaults)
                let cutoff = Calendar.current.date(byAdding: .day, value: -daysBack, to: Date()) ?? Date()
                return history.filter { $0.timestamp > cutoff }
            },

            // Legacy
            getTodayTotal: {
                let defaults = UserDefaults(suiteName: appGroupID)
                return defaults?.double(forKey: "todayTotal") ?? 0
            }
        )
    }()
    
    public static let testValue: UserSettingsManager = {
        nonisolated(unsafe) let saveApps: @Sendable (FamilyActivitySelection) async -> Void = { _ in }
        nonisolated(unsafe) let loadApps: @Sendable () async -> FamilyActivitySelection? = { nil }
        
        return Self(
            saveSelectedApps: saveApps,
            loadSelectedApps: loadApps,
            saveDailyLimit: { _ in },
            loadDailyLimit: { 240 },
            saveShieldInterval: { _ in },
            loadShieldInterval: { 20 },
            saveFocusWindow: { _ in },
            loadFocusWindow: { nil },
            saveGlobalHealth: { _ in },
            loadGlobalHealth: { 100 },
            initializeHealth: { },
            saveCooldownEnd: { _ in },
            loadCooldownEnd: { nil },
            clearCooldown: { },
            appendTimelineEvent: { _ in },
            loadTimelineEvents: { [] },
            clearTimelineEvents: { },
            saveTimelineEvents: { _ in },
            saveOnboardingProfile: { _ in },
            loadOnboardingProfile: { nil },
            appendAIMessageHistory: { _ in },
            loadAIMessageHistory: { [] },
            loadRecentAIMessages: { _ in [] },
            getTodayTotal: { 5400 }
        )
    }()

    public static let previewValue = testValue
}

// MARK: - Helper Functions

private func loadTimelineEventsSync(defaults: UserDefaults?) -> [TimelineEvent] {
    guard let data = defaults?.data(forKey: "timelineEvents"),
          let decoded = try? JSONDecoder().decode([TimelineEvent].self, from: data) else {
        return []
    }
    return decoded
}

private func loadAIMessageHistorySync(defaults: UserDefaults?) -> [AIMessageHistory] {
    guard let data = defaults?.data(forKey: "aiMessageHistory"),
          let decoded = try? JSONDecoder().decode([AIMessageHistory].self, from: data) else {
        return []
    }
    return decoded
}

// MARK: - Dependency Registration

extension DependencyValues {
    var userSettings: UserSettingsManager {
        get { self[UserSettingsManager.self] }
        set { self[UserSettingsManager.self] = newValue }
    }
}
