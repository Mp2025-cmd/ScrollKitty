import DeviceActivity
import SwiftUI

@main
struct ScrollKittyReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        DailyUsageReport { report in
            return DailyUsageReportView(report: report)
        }
    }
}
