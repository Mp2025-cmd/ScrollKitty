import DeviceActivity
import SwiftUI
import FamilyControls

extension DeviceActivityReport.Context {
    static let daily = Self("Daily")
}

struct DailyUsageReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .daily
    let content: (UsageData) -> DailyUsageReportView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> UsageData {
        print("[ScrollKittyReport] makeConfiguration called")

        // Read selected apps from App Group
        let shared = UserDefaults(suiteName: "group.com.scrollkitty.app")
        guard let selectedAppsData = shared?.data(forKey: "selectedApps"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: selectedAppsData) else {
            print("[ScrollKittyReport] No selected apps found")
            return UsageData(totalSeconds: 0)
        }

        let selectedTokens = selection.applicationTokens
        print("[ScrollKittyReport] Tracking \(selectedTokens.count) selected apps")

        // Sum ONLY selected app durations (NO WEBSITES)
        var totalSeconds: Double = 0
        for await segment in data.flatMap({ $0.activitySegments }) {
            for await category in segment.categories {
                for await app in category.applications {
                    // Only count if it's a selected app and has a valid token
                    if let token = app.application.token, selectedTokens.contains(token) {
                        totalSeconds += app.totalActivityDuration
                        print("[ScrollKittyReport] + \(app.totalActivityDuration)s from \(app.application.localizedDisplayName ?? "unknown")")
                    }
                }
            }
            // Skip webDomains entirely - we don't want Safari/Chrome time
        }

        print("[ScrollKittyReport] Calculated \(totalSeconds)s for selected apps (excluded websites)")
        return UsageData(totalSeconds: totalSeconds)
    }
}

struct UsageData {
    let totalSeconds: Double
}
