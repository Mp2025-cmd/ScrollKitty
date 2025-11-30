import DeviceActivity
import Foundation
import ManagedSettings
import FamilyControls

// SIMPLIFIED ACTIVE SHIELDING MONITOR
// Role: ONLY handles intervalDidEnd for re-shielding after cooldown.
// Initial shielding is done by main app (ScreenTimeManager.applyShields).
// Health/unlocking logic is handled by ScrollKittyAction.

class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    let store = ManagedSettingsStore()
    private let appGroupID = "group.com.scrollkitty.app"

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // NO-OP: Main app handles initial shielding.
        print("[ScrollKittyMonitor] intervalDidStart(\(activity.rawValue)) - ignored")
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        if activity.rawValue == "reshield_cooldown" {
            // Cooldown expired - re-apply shields!
            print("[ScrollKittyMonitor] ⏰ Cooldown expired - Re-shielding!")
            handleReshieldCooldown()
        } else if activity.rawValue == "daily_monitor" {
            print("[ScrollKittyMonitor] 🔴 Daily Interval Ended")
        }
    }

    // MARK: - Reshield After Cooldown

    private func handleReshieldCooldown() {
        let defaults = UserDefaults(suiteName: appGroupID)
        
        // Clear cooldown timestamp
        defaults?.removeObject(forKey: "cooldownEnd")
        
        // Check if cat is dead - if so, don't re-shield (let dead config handle it)
        let health = defaults?.integer(forKey: "catHealth") ?? 100
        if health <= 0 {
            print("[ScrollKittyMonitor] 💀 Cat is dead - keeping full lock until midnight")
            // Re-apply shields so dead config shows
            applyShields()
            return
        }

        // Re-apply shields for alive cat
        applyShields()
    }

    // MARK: - Apply Shields

    private func applyShields() {
        let defaults = UserDefaults(suiteName: appGroupID)
        guard let data = defaults?.data(forKey: "selectedApps"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            print("[ScrollKittyMonitor] ⚠️ No apps to shield")
            return
        }

        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)

        print("[ScrollKittyMonitor] 🛡️ Shields ACTIVATED (\(selection.applicationTokens.count) apps)")
    }
}
