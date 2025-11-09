import Foundation
import FamilyControls
import ComposableArchitecture

// MARK: - UserSettingsManager (TCA Dependency)

struct UserSettingsManager: Sendable {
    var saveSelectedApps: @Sendable (FamilyActivitySelection) async -> Void
    var loadSelectedApps: @Sendable () async -> FamilyActivitySelection?
    var saveDailyLimit: @Sendable (Int) async -> Void
    var loadDailyLimit: @Sendable () async -> Int?
    var getTodayTotal: @Sendable () async -> Double
}

// MARK: - Dependency Key

extension UserSettingsManager: DependencyKey {
    static let liveValue = Self(
        saveSelectedApps: { selection in
            let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
            if let encoded = try? JSONEncoder().encode(selection) {
                defaults?.set(encoded, forKey: "selectedApps")
            }
        },
        loadSelectedApps: {
            let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
            guard let data = defaults?.data(forKey: "selectedApps"),
                  let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
                return nil
            }
            return decoded
        },
        saveDailyLimit: { minutes in
            let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
            defaults?.set(minutes, forKey: "dailyLimit")
        },
        loadDailyLimit: {
            let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
            let limit = defaults?.integer(forKey: "dailyLimit")
            return limit > 0 ? limit : nil
        },
        getTodayTotal: {
            let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
            return defaults?.double(forKey: "todayTotal") ?? 0
        }
    )
    
    static let testValue = Self(
        saveSelectedApps: { _ in },
        loadSelectedApps: { nil },
        saveDailyLimit: { _ in },
        loadDailyLimit: { 240 }, // Default 4 hours
        getTodayTotal: { 5400 } // Mock: 1.5 hours
    )
    
    static let previewValue = testValue
}

// MARK: - Dependency Registration

extension DependencyValues {
    var userSettings: UserSettingsManager {
        get { self[UserSettingsManager.self] }
        set { self[UserSettingsManager.self] = newValue }
    }
}

