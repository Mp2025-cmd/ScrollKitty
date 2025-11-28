import Foundation
import ComposableArchitecture

// MARK: - Cat Health Data

struct CatHealthData: Equatable {
    let totalSeconds: Double
    let dailyLimitMinutes: Int
    let healthPercentage: Double
    let catStage: CatState
    let formattedTime: String
    
    var totalMinutes: Int {
        Int(totalSeconds / 60)
    }
    
    var totalHours: Double {
        totalSeconds / 3600
    }
}

// MARK: - CatHealthManager (TCA Dependency)

struct CatHealthManager: Sendable {
    var calculateHealth: @Sendable (Double, Int) async -> CatHealthData
    var shouldResetForNewDay: @Sendable () async -> Bool
    var performMidnightReset: @Sendable () async -> Void
}

// MARK: - Dependency Key

extension CatHealthManager: DependencyKey {
    static let liveValue = Self(
        calculateHealth: { totalSeconds, dailyLimitMinutes in
            // New Logic: Health is purely based on bypass actions, not time used.
            // Read the current health from the App Group defaults.
            let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
            let currentHealth = defaults?.double(forKey: "catHealthPercentage") ?? 100.0
            
            // Determine cat stage based on health
            let catStage: CatState
            switch currentHealth {
            case 80...100:
                catStage = .healthy
            case 60..<80:
                catStage = .concerned
            case 40..<60:
                catStage = .tired
            case 20..<40:
                catStage = .sick
            default:
                catStage = .dead
            }
            
            return await CatHealthData(
                totalSeconds: totalSeconds,
                dailyLimitMinutes: dailyLimitMinutes,
                healthPercentage: currentHealth,
                catStage: catStage,
                formattedTime: formatTime(totalSeconds)
            )
        },
        shouldResetForNewDay: {
            let defaults = UserDefaults.standard
            guard let lastReset = defaults.object(forKey: "lastResetDate") as? Date else {
                return true
            }
            return !Calendar.current.isDateInToday(lastReset)
        },
        performMidnightReset: {
            let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
            
            // Reset health to 100
            defaults?.set(100.0, forKey: "catHealthPercentage")
            defaults?.set("healthy", forKey: "catStage")
            defaults?.set(0, forKey: "selectedTotalSecondsToday") // Reset usage tracking for display if needed
            
            // Mark reset as done for today
            UserDefaults.standard.set(Date(), forKey: "lastResetDate")
            print("[CatHealthManager] 🌙 Midnight reset performed: Health restored to 100%")
        }
    )
    
    static let testValue = Self(
        calculateHealth: { totalSeconds, dailyLimitMinutes in
            await CatHealthData(
                totalSeconds: totalSeconds,
                dailyLimitMinutes: dailyLimitMinutes,
                healthPercentage: 64,
                catStage: .concerned,
                formattedTime: formatTime(totalSeconds)
            )
        },
        shouldResetForNewDay: { false },
        performMidnightReset: {}
    )
    
    static let previewValue = testValue
}

// MARK: - Dependency Registration

extension DependencyValues {
    var catHealth: CatHealthManager {
        get { self[CatHealthManager.self] }
        set { self[CatHealthManager.self] = newValue }
    }
}

// MARK: - Helper Functions

private func formatTime(_ seconds: Double) -> String {
    let hours = Int(seconds) / 3600
    let minutes = (Int(seconds) % 3600) / 60
    
    if hours > 0 {
        return "\(hours)h \(minutes)m"
    } else {
        return "\(minutes)m"
    }
}
