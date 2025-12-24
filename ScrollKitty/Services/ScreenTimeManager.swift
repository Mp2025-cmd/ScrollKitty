import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings
import ComposableArchitecture

// MARK: - Data Models

struct AppUsage: Identifiable, Equatable, Codable {
    let id: String
    let appName: String
    let duration: TimeInterval  // in seconds
    let pickups: Int
    let notifications: Int
    
    var durationHours: Double {
        duration / 3600
    }
    
    var durationMinutes: Int {
        Int(duration) / 60
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }
}

struct DailyScreenTimeData: Equatable, Codable {
    let date: Date
    let totalScreenTime: TimeInterval  // in seconds
    let appUsages: [AppUsage]
    let pickups: Int
    let notifications: Int
    
    var totalScreenTimeHours: Double {
        totalScreenTime / 3600
    }
    
    var totalScreenTimeMinutes: Int {
        Int(totalScreenTime) / 60
    }
    
    var topApps: [AppUsage] {
        appUsages.sorted { $0.duration > $1.duration }.prefix(5).map { $0 }
    }
    
    var formattedTotalScreenTime: String {
        let hours = Int(totalScreenTime) / 3600
        let minutes = (Int(totalScreenTime) % 3600) / 60
        let seconds = Int(totalScreenTime) % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }
    
    var averageAppUsage: TimeInterval {
        guard !appUsages.isEmpty else { return 0 }
        let total = appUsages.reduce(0) { $0 + $1.duration }
        return total / TimeInterval(appUsages.count)
    }
}

// MARK: - Errors

enum DeviceActivityError: Error {
    case invalidSelection
}

// MARK: - ScreenTimeManager (TCA Compliant)

struct ScreenTimeManager: Sendable {
    var getTodayScreenTime: @Sendable () async throws -> DailyScreenTimeData?
    var getScreenTimeForDate: @Sendable (Date) async throws -> DailyScreenTimeData?
    var getScreenTimeRange: @Sendable (Date, Date) async throws -> [DailyScreenTimeData]
    var checkAuthorization: @Sendable () async -> Bool
    var startMonitoring: @Sendable () async throws -> Void
    var stopMonitoring: @Sendable () async -> Void
    var applyShields: @Sendable () async -> Void
    var removeShieldsAndStartCooldown: @Sendable () async -> Void
}

// MARK: - Dependency Conformance

extension ScreenTimeManager: DependencyKey {
    static let liveValue = Self(
        getTodayScreenTime: {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else {
                return nil
            }
            let interval = DateInterval(start: today, end: tomorrow)
            
            // TODO: Implement real DeviceActivity API parsing
            // For now, this is a placeholder that needs DeviceActivity extension implementation
            return await parseScreenTimeReport(for: interval, date: today)
        },
        getScreenTimeForDate: { date in
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
                return nil
            }
            let interval = DateInterval(start: startOfDay, end: endOfDay)
            
            return await parseScreenTimeReport(for: interval, date: date)
        },
        getScreenTimeRange: { startDate, endDate in
            var results: [DailyScreenTimeData] = []
            let calendar = Calendar.current
            var currentDate = calendar.startOfDay(for: startDate)
            let finalDate = calendar.startOfDay(for: endDate)
            
            while currentDate <= finalDate {
                do {
                    let calendar = Calendar.current
                    let startOfDay = calendar.startOfDay(for: currentDate)
                    guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
                        break
                    }
                    let interval = DateInterval(start: startOfDay, end: endOfDay)
                    
                    if let data = await parseScreenTimeReport(for: interval, date: currentDate) {
                        results.append(data)
                    }
                } catch {
                }
                guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                    break
                }
                currentDate = nextDate
            }
            
            return results
        },
        checkAuthorization: {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                return true
            } catch {
                return false
            }
        },
        startMonitoring: {
            try await startDeviceActivityMonitoring()
        },
        stopMonitoring: {
            await stopDeviceActivityMonitoring()
        },
        applyShields: {
            await applyShieldsToSelectedApps()
        },
        removeShieldsAndStartCooldown: {
            await removeShieldsAndStartCooldownImpl()
        }
    )

    static let testValue = Self(
        getTodayScreenTime: {
            DailyScreenTimeData(
                date: Date(),
                totalScreenTime: 9000,
                appUsages: [
                    AppUsage(id: "com.meta.instagram", appName: "Instagram", duration: 3600, pickups: 12, notifications: 45),
                    AppUsage(id: "com.zhiliaoapp.musically", appName: "TikTok", duration: 2400, pickups: 8, notifications: 30),
                    AppUsage(id: "com.apple.mobilesafari", appName: "Safari", duration: 1800, pickups: 5, notifications: 10)
                ],
                pickups: 25,
                notifications: 85
            )
        },
        getScreenTimeForDate: { _ in nil },
        getScreenTimeRange: { _, _ in [] },
        checkAuthorization: { true },
        startMonitoring: {},
        stopMonitoring: {},
        applyShields: {},
        removeShieldsAndStartCooldown: {}
    )

    static let previewValue = testValue
}

// MARK: - TCA Dependency

extension DependencyValues {
    var screenTimeManager: ScreenTimeManager {
        get { self[ScreenTimeManager.self] }
        set { self[ScreenTimeManager.self] = newValue }
    }
}

    // MARK: - DeviceActivity Monitoring
    
    private func startDeviceActivityMonitoring() async throws {
        let center = DeviceActivityCenter()
        
        // 1. Stop any existing monitoring
        await stopDeviceActivityMonitoring()
        
        // 2. Create Schedule (All Day)
        // We monitor 24/7 so the shield is always active until unlocked
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        // 3. Start Monitoring (No Events needed for active shielding)
        let activityName = DeviceActivityName("daily_monitor")

        try center.startMonitoring(activityName, during: schedule)
    }
    
    private func stopDeviceActivityMonitoring() async {
        let center = DeviceActivityCenter()
        center.stopMonitoring([DeviceActivityName("daily_monitor")])
    }

    private func applyShieldsToSelectedApps() async {
        let store = ManagedSettingsStore()
        let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")

        guard let data = defaults?.data(forKey: "selectedApps"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return
        }

        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
    }

    private func removeShieldsAndStartCooldownImpl() async {
        let store = ManagedSettingsStore()
        let defaults = UserDefaults.appGroup
        let activityCenter = DeviceActivityCenter()

        // Get cooldown duration
        let overrideMinutes = defaults.integer(forKey: "selectedBypassMinutes")
        let configuredMinutes = defaults.integer(forKey: "shieldInterval")
        let cooldownMinutes = overrideMinutes > 0 ? overrideMinutes : configuredMinutes
        guard cooldownMinutes > 0 else {
            // Should never happen after onboarding, since user must choose a shield frequency.
            return
        }
        defaults.removeObject(forKey: "selectedBypassMinutes")

        // Set cooldown end time
        let cooldownEnd = Date().addingTimeInterval(Double(cooldownMinutes * 60))
        defaults.set(cooldownEnd.timeIntervalSince1970, forKey: "cooldownEnd")

        // Remove shields
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil

        // Schedule reshield
        let calendar = Calendar.current
        let now = Date()

        guard let endTime = calendar.date(byAdding: .minute, value: cooldownMinutes, to: now) else {
            return
        }
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)

        var startTime = now
        if cooldownMinutes < 15 {
            let shiftBack = 15 - cooldownMinutes
            startTime = calendar.date(byAdding: .minute, value: -shiftBack, to: now) ?? now
        }
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)

        guard
            let startHour = startComponents.hour,
            let startMinute = startComponents.minute,
            let endHour = endComponents.hour,
            let endMinute = endComponents.minute
        else {
            return
        }

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: startHour, minute: startMinute),
            intervalEnd: DateComponents(hour: endHour, minute: endMinute),
            repeats: false
        )

        let activityName = DeviceActivityName("reshield_cooldown")

        activityCenter.stopMonitoring([activityName])

        do {
            try activityCenter.startMonitoring(activityName, during: schedule)
        } catch {
            // Silently fail - not critical
        }
    }

// MARK: - Private Parsing Helper

private func parseScreenTimeReport(for interval: DateInterval, date: Date) -> DailyScreenTimeData? {
    // IMPORTANT: DeviceActivity doesn't provide direct API to fetch screen time
    // You need to use one of these approaches:
    //
    // Option 1: DeviceActivityReport (iOS 15+)
    //   - Create a DeviceActivityReport SwiftUI view
    //   - Apple provides the report UI, you can't access raw data directly
    //
    // Option 2: Use UserDefaults to store data from extension
    //   - DeviceActivityMonitor extension collects data
    //   - Store in shared UserDefaults (App Group)
    //   - Read from main app
    //
    // Option 3: Use native Screen Time settings
    //   - Read from device settings (limited access)
    //
    // For now, we'll use a placeholder and rely on mock data for testing
    
    // Check if we have cached data (would come from extension)
    let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
    
    if let savedData = defaults?.data(forKey: "screenTimeData_\(date.timeIntervalSince1970)"),
       let decoded = try? JSONDecoder().decode(DailyScreenTimeData.self, from: savedData) {
        return decoded
    }
    
    // Return empty data if no cached data available
    return DailyScreenTimeData(
        date: date,
        totalScreenTime: 0,
        appUsages: [],
        pickups: 0,
        notifications: 0
    )
}
