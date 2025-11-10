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
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
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
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
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
}

// MARK: - Dependency Conformance

extension ScreenTimeManager: DependencyKey {
    static let liveValue = Self(
        getTodayScreenTime: {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            let interval = DateInterval(start: today, end: tomorrow)
            
            // TODO: Implement real DeviceActivity API parsing
            // For now, this is a placeholder that needs DeviceActivity extension implementation
            return parseScreenTimeReport(for: interval, date: today)
        },
        getScreenTimeForDate: { date in
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            let interval = DateInterval(start: startOfDay, end: endOfDay)
            
            return parseScreenTimeReport(for: interval, date: date)
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
                    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                    let interval = DateInterval(start: startOfDay, end: endOfDay)
                    
                    if let data = parseScreenTimeReport(for: interval, date: currentDate) {
                        results.append(data)
                    }
                } catch {
                    print("Error fetching data for \(currentDate): \(error)")
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
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
        stopMonitoring: {}
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

    // Load selected apps from App Group
    let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
    guard let data = defaults?.data(forKey: "selectedApps"),
          let selection = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? FamilyActivitySelection else {
        print("[ScreenTime] ❌ Failed to load selected apps from UserDefaults")
        throw DeviceActivityError.invalidSelection
    }

    print("[ScreenTime] Loaded selection - Apps: \(selection.applicationTokens.count), Categories: \(selection.categoryTokens.count)")

    // Stop any existing monitoring first
    await stopDeviceActivityMonitoring()

    // Create 12 schedules (2-hour blocks throughout the day)
    // iOS limit: ~20 monitoring activities max
    for hour in stride(from: 0, through: 22, by: 2) {
        let activityName = DeviceActivityName("schedule_\(hour)_\(hour+2)")

        // Create events at 5-minute intervals (5, 10, 15... up to 115 minutes)
        var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]

        for minutes in stride(from: 5, through: 115, by: 5) {
            let eventName = DeviceActivityEvent.Name("threshold_\(hour)_\(minutes)")
            let event = DeviceActivityEvent(
                applications: selection.applicationTokens,
                categories: selection.categoryTokens,
                threshold: DateComponents(minute: minutes)
            )
            events[eventName] = event
        }

        // Create 2-hour schedule block
        let endHour = hour == 22 ? 23 : hour + 1
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: hour, minute: 0),
            intervalEnd: DateComponents(hour: endHour, minute: 59, second: 59),
            repeats: true
        )

        do {
            try center.startMonitoring(activityName, during: schedule, events: events)
            print("[ScreenTime] Started monitoring block \(hour):00-\(hour+2):00 with \(events.count) thresholds")
        } catch {
            print("[ScreenTime] Failed to start monitoring block \(hour):00-\(hour+2):00: \(error)")
        }
    }

    print("[ScreenTime] ✅ Multi-threshold monitoring started (12 schedules × 23 events = 276 thresholds)")
}

private func stopDeviceActivityMonitoring() async {
    let center = DeviceActivityCenter()

    // Stop all 12 schedules
    var activities: [DeviceActivityName] = []
    for hour in stride(from: 0, through: 22, by: 2) {
        activities.append(DeviceActivityName("schedule_\(hour)_\(hour+2)"))
    }

    center.stopMonitoring(activities)
    print("[ScreenTime] Stopped monitoring \(activities.count) schedules")
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
