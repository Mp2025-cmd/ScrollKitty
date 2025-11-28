import Foundation
@preconcurrency import FamilyControls
import ComposableArchitecture

// MARK: - UserSettingsManager (TCA Dependency)

struct UserSettingsManager: Sendable {
    nonisolated(unsafe) var saveSelectedApps: @Sendable (FamilyActivitySelection) async -> Void
    nonisolated(unsafe) var loadSelectedApps: @Sendable () async -> FamilyActivitySelection?
    var saveDailyLimit: @Sendable (Int) async -> Void
    var loadDailyLimit: @Sendable () async -> Int?
    var saveHealthCost: @Sendable (Int) async -> Void
    var loadHealthCost: @Sendable () async -> Int?
    var saveShieldInterval: @Sendable (Int) async -> Void
    var loadShieldInterval: @Sendable () async -> Int?
    var saveFocusWindow: @Sendable (FocusWindowData) async -> Void
    var loadFocusWindow: @Sendable () async -> FocusWindowData?
    var getTodayTotal: @Sendable () async -> Double
}

// MARK: - Dependency Key

extension UserSettingsManager: DependencyKey {
    static let liveValue: UserSettingsManager = {
        let saveApps: @Sendable (FamilyActivitySelection) async -> Void = { selection in
            let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
            // Use JSONEncoder for FamilyActivitySelection (Codable)
            if let encoded = try? JSONEncoder().encode(selection) {
                defaults?.set(encoded, forKey: "selectedApps")
                print("[UserSettings] ✅ Saved \(selection.applicationTokens.count) apps, \(selection.categoryTokens.count) categories")
            } else {
                print("[UserSettings] ❌ Failed to encode selection")
            }
        }

        let loadApps: @Sendable () async -> FamilyActivitySelection? = {
            let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
            guard let data = defaults?.data(forKey: "selectedApps"),
                  let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
                print("[UserSettings] No saved app selection found")
                return nil
            }
            print("[UserSettings] ✅ Loaded \(decoded.applicationTokens.count) apps, \(decoded.categoryTokens.count) categories")
            return decoded
        }
        
        return Self(
            saveSelectedApps: saveApps,
            loadSelectedApps: loadApps,
            saveDailyLimit: { minutes in
                let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
                defaults?.set(minutes, forKey: "dailyLimit")
            },
            loadDailyLimit: {
                let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
                guard let limit = defaults?.integer(forKey: "dailyLimit"), limit > 0 else {
                    return nil
                }
                return limit
            },
            saveHealthCost: { cost in
                let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
                defaults?.set(cost, forKey: "healthCostPerBypass")
            },
            loadHealthCost: {
                let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
                // Default to 10 (legacy) if not found, or handle appropriately
                let cost = defaults?.integer(forKey: "healthCostPerBypass") ?? 0
                return cost > 0 ? cost : 10 
            },
            saveShieldInterval: { minutes in
                let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
                defaults?.set(minutes, forKey: "shieldInterval")
            },
            loadShieldInterval: {
                let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
                let interval = defaults?.integer(forKey: "shieldInterval") ?? 0
                return interval > 0 ? interval : 15 // Default to 15 minutes
            },
            saveFocusWindow: { data in
                let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
                if let encoded = try? JSONEncoder().encode(data) {
                    defaults?.set(encoded, forKey: "focusWindow")
                }
            },
            loadFocusWindow: {
                let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
                guard let data = defaults?.data(forKey: "focusWindow"),
                      let decoded = try? JSONDecoder().decode(FocusWindowData.self, from: data) else {
                    return nil
                }
                return decoded
            },
            getTodayTotal: {
                let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
                return defaults?.double(forKey: "todayTotal") ?? 0
            }
        )
    }()
    
    static let testValue: UserSettingsManager = {
        let saveApps: @Sendable (FamilyActivitySelection) async -> Void = { _ in }
        let loadApps: @Sendable () async -> FamilyActivitySelection? = { nil }
        
        return Self(
            saveSelectedApps: saveApps,
            loadSelectedApps: loadApps,
            saveDailyLimit: { _ in },
            loadDailyLimit: { 240 }, // Default 4 hours
            saveHealthCost: { _ in },
            loadHealthCost: { 25 }, // Default test cost
            saveShieldInterval: { _ in },
            loadShieldInterval: { 15 },
            saveFocusWindow: { _ in },
            loadFocusWindow: { nil },
            getTodayTotal: { 5400 } // Mock: 1.5 hours
        )
    }()
    
    static let previewValue = testValue
}

// MARK: - Dependency Registration

extension DependencyValues {
    var userSettings: UserSettingsManager {
        get { self[UserSettingsManager.self] }
        set { self[UserSettingsManager.self] = newValue }
    }
}
