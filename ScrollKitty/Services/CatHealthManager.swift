import Foundation
import ComposableArchitecture

// MARK: - Cat Health Data

struct CatHealthData: Equatable, Sendable {
    let health: Int              // 0-100
    let catState: CatState
    let formattedTime: String    // For display (legacy, can be "0m" for now)
    
    var healthPercentage: Double {
        Double(health)
    }
}

// MARK: - CatHealthManager (TCA Dependency)
// READ-ONLY: This manager only reads health. ShieldActionExtension handles mutations.
// Lazy midnight reset: Automatically resets health when loading on a new day.

struct CatHealthManager: Sendable {
    var loadHealth: @Sendable () async -> CatHealthData
}

// MARK: - Dependency Key

private let appGroupID = "group.com.scrollkitty.app"

extension CatHealthManager: DependencyKey {
    static let liveValue = Self(
        // Lazy reset: Check if new day, reset if needed, then return health
        loadHealth: {
            let defaults = UserDefaults(suiteName: appGroupID)
            
            // STEP 1: Check if we need to reset for new day
            let shouldReset: Bool
            if let lastReset = defaults?.object(forKey: "lastResetDate") as? Date {
                shouldReset = !Calendar.current.isDateInToday(lastReset)
            } else {
                // No lastResetDate means first launch or edge case - reset to be safe
                shouldReset = true
            }
            
            // STEP 2: Perform lazy reset if needed
            if shouldReset {
                print("[CatHealthManager] 🌙 Lazy midnight reset triggered")
                
                // Reset health to 100
                defaults?.set(100, forKey: "catHealth")
                
                // Clear cooldown
                defaults?.removeObject(forKey: "cooldownEnd")
                
                // Clear timeline events for new day
                defaults?.removeObject(forKey: "timelineEvents")
                
                // Mark reset as done for today
                defaults?.set(Date(), forKey: "lastResetDate")
                
                print("[CatHealthManager] ✅ Reset complete: Health=100, Cooldown cleared, Timeline cleared")
            }
            
            // STEP 3: Read current health (potentially just-reset)
            let health = defaults?.integer(forKey: "catHealth") ?? 100
            let currentHealth = health > 0 ? health : 100
            
            // Map health to cat state (UI only)
            let catState = CatState.from(health: currentHealth)
            
            return CatHealthData(
                health: currentHealth,
                catState: catState,
                formattedTime: "0m" // Legacy field, not actively used
            )
        }
    )
    
    static let testValue = Self(
        loadHealth: {
            CatHealthData(
                health: 75,
                catState: .concerned,
                formattedTime: "0m"
            )
        }
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
