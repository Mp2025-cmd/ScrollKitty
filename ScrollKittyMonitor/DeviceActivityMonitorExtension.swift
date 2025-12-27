import DeviceActivity
import Foundation
import ManagedSettings
import FamilyControls

class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    let store = ManagedSettingsStore()
    private let appGroupID = "group.com.scrollkitty.app"

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        if activity.rawValue == "blocking_schedule" {
            handleBlockingScheduleStart()
        }
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        if activity.rawValue == "reshield_cooldown" {
            handleReshieldCooldown()
        } else if activity.rawValue == "blocking_schedule" {
            removeShields()
        } else if activity.rawValue == "daily_monitor" {
        }
    }

    private struct BlockingSchedule: Codable {
        let startTime: Date
        let endTime: Date
        let selectedDays: Set<Weekday>
        let isEnabled: Bool
    }

    private enum Weekday: Int, Codable {
        case sunday = 0
        case monday = 1
        case tuesday = 2
        case wednesday = 3
        case thursday = 4
        case friday = 5
        case saturday = 6
    }

    private func handleReshieldCooldown() {
        let defaults = UserDefaults(suiteName: appGroupID)

        defaults?.removeObject(forKey: "cooldownEnd")

        let health = defaults.map { CatHealthStore.readOrInitialize(in: $0) } ?? 100
        if health <= 0 {
            applyShields()
            return
        }

        if shouldApplyShieldsNow(defaults: defaults) {
            applyShields()
        } else {
            removeShields()
        }
    }

    private func handleBlockingScheduleStart() {
        let defaults = UserDefaults(suiteName: appGroupID)

        let health = defaults.map { CatHealthStore.readOrInitialize(in: $0) } ?? 100
        guard health > 0 else {
            // Cat is dead: keep shields on during the blocking window.
            applyShields()
            return
        }

        if shouldApplyShieldsNow(defaults: defaults) {
            applyShields()
        } else {
            removeShields()
        }
    }

    private func shouldApplyShieldsNow(defaults: UserDefaults?) -> Bool {
        guard let defaults else { return false }

        // Enabled schedule required.
        guard let schedule = loadBlockingSchedule(defaults: defaults) else {
            // Defensive fallback: if schedule wasn't configured yet, behave like "always active".
            return true
        }
        guard schedule.isEnabled else { return false }

        let calendar = Calendar.current
        let now = Date()

        // Selected day.
        let weekdayIndex = calendar.component(.weekday, from: now) - 1
        let weekday = Weekday(rawValue: weekdayIndex)
        guard let weekday, schedule.selectedDays.contains(weekday) else { return false }

        // Cooldown.
        let ts = defaults.double(forKey: "cooldownEnd")
        if ts > 0, Date(timeIntervalSince1970: ts) > now { return false }

        // Time window.
        let start = calendar.dateComponents([.hour, .minute], from: schedule.startTime)
        let end = calendar.dateComponents([.hour, .minute], from: schedule.endTime)
        guard let startHour = start.hour,
              let startMinute = start.minute,
              let endHour = end.hour,
              let endMinute = end.minute else { return false }

        let nowMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute

        if startMinutes == endMinutes {
            return true
        }

        if startMinutes < endMinutes {
            return nowMinutes >= startMinutes && nowMinutes < endMinutes
        } else {
            return nowMinutes >= startMinutes || nowMinutes < endMinutes
        }
    }

    private func loadBlockingSchedule(defaults: UserDefaults) -> BlockingSchedule? {
        guard let data = defaults.data(forKey: "blockingSchedule"),
              let decoded = try? JSONDecoder().decode(BlockingSchedule.self, from: data) else {
            return nil
        }
        return decoded
    }

    private func applyShields() {
        let defaults = UserDefaults(suiteName: appGroupID)

        guard let data = defaults?.data(forKey: "selectedApps"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return
        }

        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
    }

    private func removeShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }
}
