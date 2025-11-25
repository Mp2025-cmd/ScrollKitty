//
//  AppHealthManager.swift
//  ScrollKitty
//
//  Thread-safe per-app health management
//

import Foundation

// MARK: - App Health Data Model

struct AppHealthData: Codable, Equatable, Sendable {
    let appBundleIdentifier: String
    var currentHP: Double
    let maxHP: Double
    var lastBypass: Date?

    init(appBundleIdentifier: String, maxHP: Double) {
        self.appBundleIdentifier = appBundleIdentifier
        self.currentHP = maxHP
        self.maxHP = maxHP
        self.lastBypass = nil
    }
}

// MARK: - Thread-Safe App Group Defaults Actor

actor AppGroupDefaults {
    private let suiteName = "group.com.scrollkitty.app"
    private var defaults: UserDefaults?

    init() {
        self.defaults = UserDefaults(suiteName: suiteName)
    }

    // MARK: - Per-App Health Data

    func saveAppHealthData(_ data: [String: AppHealthData]) {
        guard let defaults = defaults else { return }

        if let encoded = try? JSONEncoder().encode(data) {
            defaults.set(encoded, forKey: "appHealthData")
            defaults.synchronize()
        }
    }

    func loadAppHealthData() -> [String: AppHealthData] {
        guard let defaults = defaults,
              let data = defaults.data(forKey: "appHealthData"),
              let decoded = try? JSONDecoder().decode([String: AppHealthData].self, from: data) else {
            return [:]
        }
        return decoded
    }

    // MARK: - Global Cat Health (Calculated)

    func calculateGlobalHealth() -> Double {
        let allAppHealth = loadAppHealthData()
        return allAppHealth.values.map { $0.currentHP }.reduce(0, +)
    }

    func calculateHealthPercentage() -> Double {
        let allAppHealth = loadAppHealthData()
        let totalMaxHP = allAppHealth.values.map { $0.maxHP }.reduce(0, +)
        guard totalMaxHP > 0 else { return 100.0 }

        let totalCurrentHP = allAppHealth.values.map { $0.currentHP }.reduce(0, +)
        return (totalCurrentHP / totalMaxHP) * 100.0
    }

    // MARK: - App-Specific Operations

    func deductHealthFromApp(bundleIdentifier: String, amount: Double) {
        var healthData = loadAppHealthData()

        guard var appHealth = healthData[bundleIdentifier] else { return }

        appHealth.currentHP = max(0, appHealth.currentHP - amount)
        appHealth.lastBypass = Date()
        healthData[bundleIdentifier] = appHealth

        saveAppHealthData(healthData)

        // Update global health percentage in UserDefaults for legacy compatibility
        let percentage = calculateHealthPercentage()
        defaults?.set(percentage, forKey: "catHealthPercentage")
        defaults?.synchronize()
    }

    func getAppHealth(bundleIdentifier: String) -> AppHealthData? {
        let healthData = loadAppHealthData()
        return healthData[bundleIdentifier]
    }

    // MARK: - Initialization & Reset

    func initializeAppHealth(appBundleIdentifiers: [String]) {
        guard !appBundleIdentifiers.isEmpty else { return }

        let hpPerApp = 100.0 / Double(appBundleIdentifiers.count)
        var healthData: [String: AppHealthData] = [:]

        for bundleId in appBundleIdentifiers {
            healthData[bundleId] = AppHealthData(
                appBundleIdentifier: bundleId,
                maxHP: hpPerApp
            )
        }

        saveAppHealthData(healthData)

        // Update global health
        defaults?.set(100.0, forKey: "catHealthPercentage")
        defaults?.set("healthy", forKey: "catStage")
        defaults?.synchronize()
    }

    func performMidnightReset() {
        var healthData = loadAppHealthData()

        // Reset all apps to max HP
        for (bundleId, var appHealth) in healthData {
            appHealth.currentHP = appHealth.maxHP
            appHealth.lastBypass = nil
            healthData[bundleId] = appHealth
        }

        saveAppHealthData(healthData)

        // Reset global values
        defaults?.set(100.0, forKey: "catHealthPercentage")
        defaults?.set("healthy", forKey: "catStage")
        defaults?.set(0.0, forKey: "selectedTotalSecondsToday")
        defaults?.synchronize()
    }

    func isCatDead() -> Bool {
        return calculateGlobalHealth() <= 0
    }

    // MARK: - App Count

    func getSelectedAppCount() -> Int {
        return loadAppHealthData().count
    }

    // MARK: - Migration Helper

    func hasOldLivesData() -> Bool {
        guard let defaults = defaults else { return false }
        return defaults.object(forKey: "catLivesCurrent") != nil
    }

    func clearOldLivesData() {
        defaults?.removeObject(forKey: "catLivesMax")
        defaults?.removeObject(forKey: "catLivesCurrent")
        defaults?.synchronize()
    }
}
