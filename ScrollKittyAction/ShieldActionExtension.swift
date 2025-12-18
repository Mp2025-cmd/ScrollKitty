import ManagedSettings
import ManagedSettingsUI
import Foundation
import FamilyControls
import DeviceActivity

private struct TimelineEvent: Codable {
    let id: String  // UUID string
    let timestamp: Date
    let appName: String
    let healthBefore: Int
    let healthAfter: Int
    let cooldownStarted: Date
    let eventType: String  // "shieldShown" or "shieldBypassed"
    let message: String?
    let emoji: String?
    let trigger: String?
    
    // Backward compatibility keys
    private enum CodingKeys: String, CodingKey {
        case id, timestamp, appName, healthBefore, healthAfter, cooldownStarted, eventType, trigger
        case message, emoji
        case aiMessage, aiEmoji
    }

    init(
        id: String = UUID().uuidString,
        timestamp: Date,
        appName: String,
        healthBefore: Int,
        healthAfter: Int,
        cooldownStarted: Date,
        eventType: String,
        message: String? = nil,
        emoji: String? = nil,
        trigger: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.appName = appName
        self.healthBefore = healthBefore
        self.healthAfter = healthAfter
        self.cooldownStarted = cooldownStarted
        self.eventType = eventType
        self.message = message
        self.emoji = emoji
        self.trigger = trigger
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        appName = try container.decode(String.self, forKey: .appName)
        healthBefore = try container.decode(Int.self, forKey: .healthBefore)
        healthAfter = try container.decode(Int.self, forKey: .healthAfter)
        cooldownStarted = try container.decode(Date.self, forKey: .cooldownStarted)
        eventType = try container.decode(String.self, forKey: .eventType)
        trigger = try container.decodeIfPresent(String.self, forKey: .trigger)
        
        // Try new keys first, fall back to old keys
        if let msg = try container.decodeIfPresent(String.self, forKey: .message) {
            message = msg
        } else {
            message = try container.decodeIfPresent(String.self, forKey: .aiMessage)
        }
        
        if let emj = try container.decodeIfPresent(String.self, forKey: .emoji) {
            emoji = emj
        } else {
            emoji = try container.decodeIfPresent(String.self, forKey: .aiEmoji)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(appName, forKey: .appName)
        try container.encode(healthBefore, forKey: .healthBefore)
        try container.encode(healthAfter, forKey: .healthAfter)
        try container.encode(cooldownStarted, forKey: .cooldownStarted)
        try container.encode(eventType, forKey: .eventType)
        try container.encodeIfPresent(trigger, forKey: .trigger)
        
        // Encode with new keys only
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(emoji, forKey: .emoji)
    }
}

class ShieldActionExtension: ShieldActionDelegate {

    private let store = ManagedSettingsStore()
    private let activityCenter = DeviceActivityCenter()
    private let appGroupID = "group.com.scrollkitty.app"

    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
        case .secondaryButtonPressed:
            handleBypass(appName: "App") {
                self.startGlobalCooldown()
                completionHandler(.none)
            }
        @unknown default:
            completionHandler(.close)
        }
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
        case .secondaryButtonPressed:
            handleBypass(appName: "Website") {
                self.startGlobalCooldown()
                completionHandler(.none)
            }
        @unknown default:
            completionHandler(.close)
        }
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
        case .secondaryButtonPressed:
            handleBypass(appName: "Category") {
                self.startGlobalCooldown()
                completionHandler(.none)
            }
        @unknown default:
            completionHandler(.close)
        }
    }

    private func handleBypass(appName: String, completion: () -> Void) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            completion()
            return
        }

        let currentHealth = defaults.integer(forKey: "catHealth")

        if currentHealth == 0 && defaults.object(forKey: "catHealth") != nil {
            return
        }

        let healthBefore = currentHealth > 0 ? currentHealth : 100

        let healthAfter = max(0, healthBefore - 5)

        defaults.set(healthAfter, forKey: "catHealth")

        let now = Date()
        trackSessionStart(defaults: defaults, now: now)

        logTimelineEvent(
            defaults: defaults,
            appName: appName,
            healthBefore: healthBefore,
            healthAfter: healthAfter,
            cooldownStarted: now,
            eventType: "shieldBypassed"
        )

        completion()
    }

    private func trackSessionStart(defaults: UserDefaults, now: Date) {
        if defaults.object(forKey: "firstBypassTime") == nil {
            defaults.set(now, forKey: "firstBypassTime")
        }

        defaults.set(now, forKey: "lastBypassTime")

        defaults.set(now, forKey: "sessionStartTime")
    }

    private func startGlobalCooldown() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            return
        }

        let cooldownMinutes = defaults.integer(forKey: "shieldInterval")
        let duration = cooldownMinutes > 0 ? cooldownMinutes : 20

        autoreleasepool {
            let cooldownEnd = Date().addingTimeInterval(Double(duration * 60))
            defaults.set(cooldownEnd.timeIntervalSince1970, forKey: "cooldownEnd")

            _ = defaults.synchronize()
        }

        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil

        scheduleReshield(cooldownMinutes: duration)
    }

    private func scheduleReshield(cooldownMinutes: Int) {
        let calendar = Calendar.current
        let now = Date()

        let endTime = calendar.date(byAdding: .minute, value: cooldownMinutes, to: now)!
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)

        var startTime = now
        if cooldownMinutes < 15 {
            let shiftBack = 15 - cooldownMinutes
            startTime = calendar.date(byAdding: .minute, value: -shiftBack, to: now)!
        }
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: startComponents.hour, minute: startComponents.minute),
            intervalEnd: DateComponents(hour: endComponents.hour, minute: endComponents.minute),
            repeats: false
        )

        let activityName = DeviceActivityName("reshield_cooldown")

        activityCenter.stopMonitoring([activityName])

        do {
            try activityCenter.startMonitoring(activityName, during: schedule)
        } catch {
        }
    }

    private func logTimelineEvent(
        defaults: UserDefaults,
        appName: String,
        healthBefore: Int,
        healthAfter: Int,
        cooldownStarted: Date,
        eventType: String
    ) {
        var events: [TimelineEvent] = []
        if let data = defaults.data(forKey: "timelineEvents"),
           let decoded = try? JSONDecoder().decode([TimelineEvent].self, from: data) {
            events = decoded
        }

        let now = Date()
        let recentDuplicate = events.contains { event in
            event.healthBefore == healthBefore &&
            event.healthAfter == healthAfter &&
            now.timeIntervalSince(event.timestamp) < 3.0
        }

        if recentDuplicate {
            return
        }

        let event = TimelineEvent(
            timestamp: now,
            appName: appName,
            healthBefore: healthBefore,
            healthAfter: healthAfter,
            cooldownStarted: cooldownStarted,
            eventType: eventType
        )
        events.append(event)

        if events.count > 100 {
            events = Array(events.suffix(100))
        }

        if let encoded = try? JSONEncoder().encode(events) {
            defaults.set(encoded, forKey: "timelineEvents")
        }
    }
}
