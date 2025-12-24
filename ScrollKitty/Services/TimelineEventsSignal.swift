import Foundation

enum TimelineEventsSignal {
    static let name = "com.scrollkitty.timelineEventsDidChange"

    static func post() {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(
            center,
            CFNotificationName(name as CFString),
            nil,
            nil,
            true
        )
    }
}

