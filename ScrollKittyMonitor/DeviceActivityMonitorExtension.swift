import DeviceActivity
import Foundation
import UserNotifications
import ManagedSettings
import FamilyControls

// SIMPLIFIED ACTIVE SHIELDING MONITOR
// Role: ONLY handles intervalDidEnd for re-shielding after cooldown.
// Initial shielding is done by main app (ScreenTimeManager.applyShields).
// Health/unlocking logic is handled by ScrollKittyAction.

class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    let store = ManagedSettingsStore()

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // NO-OP: Main app handles initial shielding.
        // This only fires to indicate we're "inside" the scheduled interval.
        print("[ScrollKittyMonitor] intervalDidStart(\(activity.rawValue)) - ignored (main app handles shielding)")
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        if activity.rawValue == "reshield_cooldown" {
            // Cooldown expired - re-apply shields!
            print("[ScrollKittyMonitor] ⏰ Cooldown expired - Re-shielding!")
            handleReshieldCooldown()
        } else if activity.rawValue == "daily_monitor" {
            // End of day - could clear shields here if needed
            print("[ScrollKittyMonitor] 🔴 Daily Interval Ended")
            // Note: We don't clear shields here anymore since main app controls them
        }
    }

    // MARK: - Reshield After Cooldown

    private func handleReshieldCooldown() {
        // Clear the unblock expiration
        let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
        defaults?.removeObject(forKey: "unblockExpiration")

        // Re-apply shields
        applyShields()

        // Send notification
        sendReshieldNotification()
    }

    // MARK: - Shared Logic

    private func applyShields() {
        let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
        guard let data = defaults?.data(forKey: "selectedApps"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            print("[ScrollKittyMonitor] ⚠️ No apps to shield")
            return
        }

        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)

        print("[ScrollKittyMonitor] 🛡️ Shields ACTIVATED")
    }

    private func sendReshieldNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Shield Activated"
        content.body = "Your cooldown has ended. Apps are blocked again."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "reshield-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
