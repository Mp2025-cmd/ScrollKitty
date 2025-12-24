import Foundation
import ComposableArchitecture

struct CatHealthData: Equatable, Sendable {
    let health: Int
    let catState: CatState
    let formattedTime: String

    var healthPercentage: Double {
        Double(health)
    }
}

struct CatHealthManager: Sendable {
    var loadHealth: @Sendable () async -> CatHealthData
}

private let appGroupID = "group.com.scrollkitty.app"

extension CatHealthManager: DependencyKey {
    static let liveValue = Self(
        loadHealth: {
            @Dependency(\.userSettings) var userSettings

            let defaults = UserDefaults(suiteName: appGroupID)
            let now = Date()
            let calendar = Calendar.current

            if let defaults,
               let lastReset = defaults.object(forKey: "lastResetDate") as? Date,
               !calendar.isDateInToday(lastReset) {
                let dayStart = calendar.startOfDay(for: lastReset)
                let summaryKey = "closingMessageDate_\(calendar.component(.year, from: dayStart))_\(calendar.component(.dayOfYear, from: dayStart))"

                if !defaults.bool(forKey: summaryKey) {
                    let healthAtEnd = CatHealthStore.readOrInitialize(in: defaults)
                    let trigger: DailySummaryContext.Trigger = (healthAtEnd == 0) ? .terminal : .nightly

                    let dailyLimitMinutes = await userSettings.loadDailyLimit()
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "h:mm a"

                    let bypassCountToday = defaults.integer(forKey: "bypassCountToday")
                    let totalBypassMinutesToday = defaults.integer(forKey: "totalBypassMinutesToday")
                    let firstBypass = defaults.object(forKey: "firstBypassTimeToday") as? Date
                    let lastBypass = defaults.object(forKey: "lastBypassTimeToday") as? Date

                    let context = DailySummaryContext(
                        trigger: trigger,
                        catHealth: healthAtEnd,
                        healthBand: HealthBasedMessages.band(for: healthAtEnd),
                        dailyLimitMinutes: dailyLimitMinutes,
                        bypassCountToday: bypassCountToday,
                        totalBypassMinutesToday: totalBypassMinutesToday,
                        firstBypassTimeToday: firstBypass.map { timeFormatter.string(from: $0) },
                        lastBypassTimeToday: lastBypass.map { timeFormatter.string(from: $0) }
                    )

                    let recentMessages = await userSettings.loadRecentMessages(5)
                    let message = DailySummaryTemplates.select(context: context, recentMessages: recentMessages)

                    let endOfDay = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: dayStart) ?? dayStart

                    let historyEntry = MessageHistory(
                        timestamp: endOfDay,
                        trigger: trigger == .terminal ? TimelineEntryTrigger.terminal.rawValue : TimelineEntryTrigger.nightly.rawValue,
                        healthBand: healthAtEnd,
                        response: message,
                        emoji: nil
                    )
                    await userSettings.appendMessageHistory(historyEntry)

                    let event = TimelineEvent(
                        id: UUID(),
                        timestamp: endOfDay,
                        appName: trigger == .terminal ? "Terminal" : "Nightly",
                        healthBefore: healthAtEnd,
                        healthAfter: healthAtEnd,
                        cooldownStarted: endOfDay,
                        eventType: .templateGenerated,
                        message: message,
                        emoji: nil,
                        trigger: trigger == .terminal ? TimelineEntryTrigger.terminal.rawValue : TimelineEntryTrigger.nightly.rawValue
                    )
                    await userSettings.appendTimelineEvent(event)

                    defaults.set(true, forKey: summaryKey)
                }

                autoreleasepool {
                    defaults.set(100, forKey: "catHealth")
                    defaults.removeObject(forKey: "cooldownEnd")
                    defaults.removeObject(forKey: "bypassCountToday")
                    defaults.removeObject(forKey: "totalBypassMinutesToday")
                    defaults.removeObject(forKey: "firstBypassTimeToday")
                    defaults.removeObject(forKey: "lastBypassTimeToday")
                    defaults.set(now, forKey: "lastResetDate")
                    defaults.synchronize()
                }
            } else if defaults?.object(forKey: "lastResetDate") == nil {
                // First run: initialize without generating a "yesterday" summary.
                autoreleasepool {
                    defaults?.set(100, forKey: "catHealth")
                    defaults?.set(now, forKey: "lastResetDate")
                    defaults?.synchronize()
                }
            }

            let currentHealth = defaults.map { CatHealthStore.readOrInitialize(in: $0) } ?? 100
            let catState = CatState.from(health: currentHealth)

            return CatHealthData(
                health: currentHealth,
                catState: catState,
                formattedTime: "0m"
            )
        }
    )

    static let testValue = Self(
        loadHealth: {
            CatHealthData(
                health: 75,
                catState: .concerned,
                formattedTime: "0m"
            )
        }
    )

    static let previewValue = testValue
}

extension DependencyValues {
    var catHealth: CatHealthManager {
        get { self[CatHealthManager.self] }
        set { self[CatHealthManager.self] = newValue }
    }
}
