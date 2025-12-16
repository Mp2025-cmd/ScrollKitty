import Foundation
import ComposableArchitecture

struct CatHealthData: Equatable, Sendable {
    let health: Int
    let catState: CatState
    let formattedTime: String

    var healthPercentage: Double {
        Double(health)
    }
}

struct CatHealthManager: Sendable {
    var loadHealth: @Sendable () async -> CatHealthData
}

private let appGroupID = "group.com.scrollkitty.app"

extension CatHealthManager: DependencyKey {
    static let liveValue = Self(
        loadHealth: {
            let defaults = UserDefaults(suiteName: appGroupID)

            let shouldReset: Bool
            if let lastReset = defaults?.object(forKey: "lastResetDate") as? Date {
                shouldReset = !Calendar.current.isDateInToday(lastReset)
            } else {
                shouldReset = true
            }

            if shouldReset {
                autoreleasepool {
                    defaults?.set(100, forKey: "catHealth")
                    defaults?.removeObject(forKey: "cooldownEnd")
                    defaults?.removeObject(forKey: "timelineEvents")
                    defaults?.removeObject(forKey: "sessionStartTime")
                    defaults?.removeObject(forKey: "cumulativePhoneUseSeconds")
                    defaults?.removeObject(forKey: "firstBypassTime")
                    defaults?.removeObject(forKey: "lastBypassTime")
                    defaults?.set(Date(), forKey: "lastResetDate")
                    defaults?.synchronize()
                }
            }

            let health = defaults?.integer(forKey: "catHealth") ?? 100
            let currentHealth = defaults?.object(forKey: "catHealth") != nil ? health : 100
            let catState = CatState.from(health: currentHealth)

            return CatHealthData(
                health: currentHealth,
                catState: catState,
                formattedTime: "0m"
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

extension DependencyValues {
    var catHealth: CatHealthManager {
        get { self[CatHealthManager.self] }
        set { self[CatHealthManager.self] = newValue }
    }
}
