import Foundation
@preconcurrency import FamilyControls
import ComposableArchitecture

// MARK: - UserSettingsManager (TCA Dependency)

struct UserSettingsManager: Sendable {
    nonisolated(unsafe) var saveSelectedApps: @Sendable (FamilyActivitySelection) async -> Void
    nonisolated(unsafe) var loadSelectedApps: @Sendable () async -> FamilyActivitySelection?
    var saveDailyLimit: @Sendable (Int) async -> Void
    var loadDailyLimit: @Sendable () async -> Int?
    var getTodayTotal: @Sendable () async -> Double
}

// MARK: - Dependency Key

extension UserSettingsManager: DependencyKey {
    static let liveValue: UserSettingsManager = {
        nonisolated(unsafe) let saveApps: @Sendable (FamilyActivitySelection) async -> Void = { selection in
            let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
            // Use JSONEncoder for FamilyActivitySelection (Codable)
            if let encoded = try? JSONEncoder().encode(selection) {
                defaults?.set(encoded, forKey: "selectedApps")
                print("[UserSettings] ✅ Saved \(selection.applicationTokens.count) apps, \(selection.categoryTokens.count) categories")
            } else {
                print("[UserSettings] ❌ Failed to encode selection")
            }
        }

        nonisolated(unsafe) let loadApps: @Sendable () async -> FamilyActivitySelection? = {
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
            getTodayTotal: {
                let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
                return defaults?.double(forKey: "todayTotal") ?? 0
            }
        )
    }()
    
    static let testValue: UserSettingsManager = {
        nonisolated(unsafe) let saveApps: @Sendable (FamilyActivitySelection) async -> Void = { _ in }
        nonisolated(unsafe) let loadApps: @Sendable () async -> FamilyActivitySelection? = { nil }
        
        return Self(
            saveSelectedApps: saveApps,
            loadSelectedApps: loadApps,
            saveDailyLimit: { _ in },
            loadDailyLimit: { 240 }, // Default 4 hours
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

