import SwiftUI

struct DailyUsageReportView: View {
    let report: UsageData
    @State private var lastWrittenValue: Double = -1

    var body: some View {
        EmptyView()
            .onAppear {
                writeData()
            }
            .onChange(of: report.totalSeconds) { newValue in
                if newValue != lastWrittenValue {
                    writeData()
                }
            }
    }

    private func writeData() {
        guard let shared = UserDefaults(suiteName: "group.com.scrollkitty.app") else {
            print("[ScrollKittyReport] ❌ Failed to access App Group UserDefaults")
            return
        }

        shared.set(report.totalSeconds, forKey: "selectedTotalSecondsToday")
        shared.set(Date(), forKey: "lastActivityUpdate")
        lastWrittenValue = report.totalSeconds

        print("[ScrollKittyReport] ✅ Wrote \(report.totalSeconds)s (\(Int(report.totalSeconds/60))m) to UserDefaults (apps only)")
    }
}
