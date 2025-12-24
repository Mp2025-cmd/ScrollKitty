import Foundation

enum CatHealthStore {
    static let key = "catHealth"
    static let defaultHealth = 100

    static func readOrInitialize(in defaults: UserDefaults) -> Int {
        if defaults.object(forKey: key) == nil {
            defaults.set(defaultHealth, forKey: key)
            return defaultHealth
        }
        return defaults.integer(forKey: key)
    }
}

