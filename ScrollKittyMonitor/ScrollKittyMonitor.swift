import DeviceActivity
import Foundation
import FamilyControls
import ManagedSettings

// MARK: - DeviceActivityMonitor Extension
// Tracks real app usage via thresholds and writes to App Group UserDefaults

@MainActor
class ScrollKittyMonitorExtension: DeviceActivityMonitor {

    nonisolated(unsafe) private let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
    private let todayTotalKey = "todayTotal"
    private let lastUpdateKey = "lastUpdate"

    nonisolated override init() {
        super.init()
        print("[ScrollKitty Extension] Extension initialized")
    }

    // MARK: - Lifecycle

    /// Called at start of each 2-hour block
    nonisolated override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        print("[ScrollKitty Extension] intervalDidStart for activity: \(activity.rawValue)")

        // Only reset at midnight (schedule_0_2 block)
        if activity.rawValue.contains("schedule_0") {
            defaults?.set(0.0, forKey: todayTotalKey)
            defaults?.set(Date(), forKey: lastUpdateKey)
            print("[ScrollKitty Extension] Midnight reset - cleared daily counter")
        }
    }

    nonisolated override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        // Log at end of last block (schedule_22_24)
        if activity.rawValue.contains("schedule_22") {
            let totalMinutes = Int((defaults?.double(forKey: todayTotalKey) ?? 0) / 60)
            print("[ScrollKitty Extension] Day ended - Total: \(totalMinutes)m")
        }
    }

    // MARK: - Threshold Events

    /// Called when 5-minute threshold reached - always adds 5 minutes
    nonisolated override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)

        // Always add 5 minutes (300 seconds) - the granularity of our thresholds
        let currentTotal = defaults?.double(forKey: todayTotalKey) ?? 0
        let newTotal = currentTotal + 300 // 5 minutes in seconds

        defaults?.set(newTotal, forKey: todayTotalKey)
        defaults?.set(Date(), forKey: lastUpdateKey)

        // Parse event name for logging (e.g., "threshold_14_35" = 2pm block, 35min mark)
        let eventName = event.rawValue
        let totalMinutes = Int(newTotal / 60)
        print("[ScrollKitty Extension] Threshold \(eventName) reached - Total: \(totalMinutes)m")
    }

    /// Called when approaching daily limit
    nonisolated override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        print("[ScrollKitty Extension] Warning: Approaching daily limit")
    }
}
