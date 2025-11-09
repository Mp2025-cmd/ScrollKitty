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
            guard dailyLimitMinutes > 0 else {
                return CatHealthData(
                    totalSeconds: totalSeconds,
                    dailyLimitMinutes: dailyLimitMinutes,
                    healthPercentage: 100,
                    catStage: .healthy,
                    formattedTime: formatTime(totalSeconds)
                )
            }
            
            let totalMinutes = totalSeconds / 60
            let usedRatio = totalMinutes / Double(dailyLimitMinutes)
            let healthPercentage = max(0, min(100, 100 - (usedRatio * 100)))
            
            // Determine cat stage based on health
            let catStage: CatState
            switch healthPercentage {
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
            
            return CatHealthData(
                totalSeconds: totalSeconds,
                dailyLimitMinutes: dailyLimitMinutes,
                healthPercentage: healthPercentage,
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
            defaults?.set(0, forKey: "todayTotal")
            
            UserDefaults.standard.set(Date(), forKey: "lastResetDate")
        }
    )
    
    static let testValue = Self(
        calculateHealth: { totalSeconds, dailyLimitMinutes in
            CatHealthData(
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

