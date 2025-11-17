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

        // Sum ALL app durations (NO WEBSITES)
        var totalSeconds: Double = 0
        for await segment in data.flatMap({ $0.activitySegments }) {
            for await category in segment.categories {
                for await app in category.applications {
                    totalSeconds += app.totalActivityDuration
                    print("[ScrollKittyReport] + \(app.totalActivityDuration)s from \(app.application.localizedDisplayName ?? "unknown")")
                }
            }
            // Skip webDomains entirely - we don't want Safari/Chrome time
        }

        print("[ScrollKittyReport] Calculated \(totalSeconds)s total (excluded websites)")
        return UsageData(totalSeconds: totalSeconds)
    }
}

struct UsageData {
    let totalSeconds: Double
}
