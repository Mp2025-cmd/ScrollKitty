import Foundation

enum CatHealthStore {
    static let key = "catHealth"
    static let defaultHealth = 100

    /// Reads `catHealth` from storage.
    /// If missing, initializes to 100, persists it, and returns 100.
    static func readOrInitialize(in defaults: UserDefaults) -> Int {
        if defaults.object(forKey: key) == nil {
            defaults.set(defaultHealth, forKey: key)
            return defaultHealth
        }
        return defaults.integer(forKey: key)
    }

    static func set(_ health: Int, in defaults: UserDefaults) {
        let clamped = max(0, min(100, health))
        defaults.set(clamped, forKey: key)
    }
}

