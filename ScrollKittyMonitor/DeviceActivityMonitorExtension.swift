import DeviceActivity
import Foundation
import UserNotifications
import ManagedSettings
import FamilyControls

// ACTIVE SHIELDING MONITOR
// Role: Simply turns the "Shields" ON at the start of the day/interval.
// The actual logic for health/unlocking is handled by ScrollKittyAction.

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    let store = ManagedSettingsStore()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("[ScrollKittyMonitor] 🟢 Interval Started (Shields ON)")
        
        // 1. Load Selected Apps
        let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
        guard let data = defaults?.data(forKey: "selectedApps"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) as FamilyActivitySelection else {
            print("[ScrollKittyMonitor] ⚠️ No apps to shield")
            return
        }
        
        // 2. Apply Shield Immediately
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        // We skip web domains to avoid over-blocking issues
        
        print("[ScrollKittyMonitor] 🛡️ Shields ACTIVATED")
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("[ScrollKittyMonitor] 🔴 Interval Ended (Shields OFF)")
        
        // 3. Clear Shields (e.g. end of day or user stopped monitoring)
        store.clearAllSettings()
        print("[ScrollKittyMonitor] 🛡️ Shields CLEARED")
    }
    
    // Note: We removed eventDidReachThreshold because it's flaky on iOS 26.
    // We rely entirely on ShieldActionExtension for logic.
}
