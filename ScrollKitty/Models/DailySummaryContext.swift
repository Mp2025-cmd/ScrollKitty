import Foundation

struct DailySummaryContext: Sendable {
    enum Trigger: String, Sendable {
        case nightly
        case terminal
    }

    let trigger: Trigger
    let catHealth: Int
    let healthBand: HealthBasedMessages.Band
    let dailyLimitMinutes: Int?
    let bypassCountToday: Int
    let totalBypassMinutesToday: Int
    let firstBypassTimeToday: String?
    let lastBypassTimeToday: String?

    var overByMinutes: Int? {
        guard let dailyLimitMinutes else { return nil }
        return max(0, totalBypassMinutesToday - dailyLimitMinutes)
    }

    var underByMinutes: Int? {
        guard let dailyLimitMinutes else { return nil }
        return max(0, dailyLimitMinutes - totalBypassMinutesToday)
    }
}

