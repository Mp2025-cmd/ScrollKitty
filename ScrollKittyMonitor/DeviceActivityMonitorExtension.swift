import DeviceActivity
import Foundation
import ManagedSettings
import FamilyControls

class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    let store = ManagedSettingsStore()
    private let appGroupID = "group.com.scrollkitty.app"

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        if activity.rawValue == "reshield_cooldown" {
            handleReshieldCooldown()
        } else if activity.rawValue == "daily_monitor" {
        }
    }

    private func handleReshieldCooldown() {
        let defaults = UserDefaults(suiteName: appGroupID)

        defaults?.removeObject(forKey: "cooldownEnd")

        let health = defaults?.integer(forKey: "catHealth") ?? 100
        if health <= 0 {
            applyShields()
            return
        }

        applyShields()
    }

    private func applyShields() {
        let defaults = UserDefaults(suiteName: appGroupID)

        accumulateSessionTime(defaults: defaults)

        guard let data = defaults?.data(forKey: "selectedApps"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return
        }

        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
    }

    private func accumulateSessionTime(defaults: UserDefaults?) {
        guard let defaults = defaults,
              let sessionStart = defaults.object(forKey: "sessionStartTime") as? Date else {
            return
        }

        let elapsed = Date().timeIntervalSince(sessionStart)

        let currentTotal = defaults.double(forKey: "cumulativePhoneUseSeconds")
        let newTotal = currentTotal + elapsed
        defaults.set(newTotal, forKey: "cumulativePhoneUseSeconds")

        defaults.removeObject(forKey: "sessionStartTime")
    }
}
