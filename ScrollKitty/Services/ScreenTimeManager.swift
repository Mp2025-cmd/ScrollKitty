import Foundation
import DeviceActivity
import FamilyControls
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

// MARK: - ScreenTimeManager (TCA Compliant)

struct ScreenTimeManager: Sendable {
    var getTodayScreenTime: @Sendable () async throws -> DailyScreenTimeData?
    var getScreenTimeForDate: @Sendable (Date) async throws -> DailyScreenTimeData?
    var getScreenTimeRange: @Sendable (Date, Date) async throws -> [DailyScreenTimeData]
    var checkAuthorization: @Sendable () async -> Bool
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
        checkAuthorization: { true }
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

// MARK: - Private Parsing Helper

private func parseScreenTimeReport(for interval: DateInterval, date: Date) -> DailyScreenTimeData? {
    // TODO: Implement actual DeviceActivity report parsing
    // This requires using DeviceActivityMonitor extension to monitor and collect data
    // For now, return placeholder structure
    
    // Note: DeviceActivity API requires a DeviceActivityMonitor extension
    // which runs in the background and collects usage data
    
    let totalScreenTime: TimeInterval = 0
    let appUsages: [AppUsage] = []
    let pickups: Int = 0
    let notifications: Int = 0
    
    return DailyScreenTimeData(
        date: date,
        totalScreenTime: totalScreenTime,
        appUsages: appUsages,
        pickups: pickups,
        notifications: notifications
    )
}
