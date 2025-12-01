import ManagedSettings
import ManagedSettingsUI
import Foundation
import FamilyControls
import DeviceActivity

// MARK: - Timeline Event (Duplicated for Extension - Extensions can't share code with main app)

private struct TimelineEvent: Codable {
    let id: String  // UUID string
    let timestamp: Date
    let appName: String
    let healthBefore: Int
    let healthAfter: Int
    let cooldownStarted: Date
    let eventType: String  // "shieldShown" or "shieldBypassed"
    let aiMessage: String?
    let aiEmoji: String?
    let trigger: String?
    let showFallbackNotice: Bool
    
    init(
        id: String = UUID().uuidString,
        timestamp: Date,
        appName: String,
        healthBefore: Int,
        healthAfter: Int,
        cooldownStarted: Date,
        eventType: String,
        aiMessage: String? = nil,
        aiEmoji: String? = nil,
        trigger: String? = nil,
        showFallbackNotice: Bool = false
    ) {
        self.id = id
        self.timestamp = timestamp
        self.appName = appName
        self.healthBefore = healthBefore
        self.healthAfter = healthAfter
        self.cooldownStarted = cooldownStarted
        self.eventType = eventType
        self.aiMessage = aiMessage
        self.aiEmoji = aiEmoji
        self.trigger = trigger
        self.showFallbackNotice = showFallbackNotice
    }
}

// MARK: - Shield Action Extension

class ShieldActionExtension: ShieldActionDelegate {

    private let store = ManagedSettingsStore()
    private let activityCenter = DeviceActivityCenter()
    private let appGroupID = "group.com.scrollkitty.app"

    // MARK: - Applications
    
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // "Step Back" (alive) or "Close App" (dead)
            completionHandler(.close)
            
        case .secondaryButtonPressed:
            // "Continue / Bypass" - Only available when alive
            handleBypass(appName: "App") {
                self.startGlobalCooldown()
                completionHandler(.none)
            }
            
        @unknown default:
            completionHandler(.close)
        }
    }
    
    // MARK: - Web Domains
    
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
    
    // MARK: - Categories
    
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
    
    // MARK: - Core Bypass Logic
    
    private func handleBypass(appName: String, completion: () -> Void) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            print("[ShieldAction] ❌ Failed to access App Group")
            completion()
            return
        }
        
        // Read current health
        let currentHealth = defaults.integer(forKey: "catHealth")
        let healthBefore = currentHealth > 0 ? currentHealth : 100
        
        // If already dead, don't allow bypass (shouldn't happen - shield config hides button)
        if healthBefore <= 0 {
            print("[ShieldAction] ⚠️ Cat is dead - bypass blocked")
            return
        }
        
        // Subtract 5 HP (fixed cost)
        let healthAfter = max(0, healthBefore - 5)
        
        // Save new health
        defaults.set(healthAfter, forKey: "catHealth")
        
        // Log timeline event
        let now = Date()
        logTimelineEvent(
            defaults: defaults,
            appName: appName,
            healthBefore: healthBefore,
            healthAfter: healthAfter,
            cooldownStarted: now,
            eventType: "shieldBypassed"
        )
        
        print("[ShieldAction] 📉 Health: \(healthBefore) → \(healthAfter) (-5 HP)")
        
        completion()
    }
    
    // MARK: - Global Cooldown
    
    private func startGlobalCooldown() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        
        // Get cooldown duration (default: 20 minutes)
        let cooldownMinutes = defaults.integer(forKey: "shieldInterval")
        let duration = cooldownMinutes > 0 ? cooldownMinutes : 20
        
        // Set global cooldown end time
        let cooldownEnd = Date().addingTimeInterval(Double(duration * 60))
        defaults.set(cooldownEnd.timeIntervalSince1970, forKey: "cooldownEnd")
        
        // GLOBAL COOLDOWN: Clear ALL shields (not just the bypassed app)
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        
        print("[ShieldAction] ⏱️ Global cooldown started: \(duration) minutes - ALL shields cleared")
        
        // Schedule re-shield when cooldown ends
        scheduleReshield(cooldownMinutes: duration)
    }
    
    // MARK: - Re-shield Scheduling
    
    private func scheduleReshield(cooldownMinutes: Int) {
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate end time
        let endTime = calendar.date(byAdding: .minute, value: cooldownMinutes, to: now)!
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        // DeviceActivitySchedule requires minimum 15-minute interval
        // If cooldown < 15 min, shift start backwards to create valid interval
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
        
        // Stop any existing schedule
        activityCenter.stopMonitoring([activityName])
        
        do {
            try activityCenter.startMonitoring(activityName, during: schedule)
            print("[ShieldAction] ⏰ Re-shield scheduled for \(endComponents.hour ?? 0):\(String(format: "%02d", endComponents.minute ?? 0))")
        } catch {
            print("[ShieldAction] ❌ Failed to schedule re-shield: \(error)")
        }
    }
    
    // MARK: - Timeline Logging
    
    private func logTimelineEvent(
        defaults: UserDefaults,
        appName: String,
        healthBefore: Int,
        healthAfter: Int,
        cooldownStarted: Date,
        eventType: String
    ) {
        // Load existing events
        var events: [TimelineEvent] = []
        if let data = defaults.data(forKey: "timelineEvents"),
           let decoded = try? JSONDecoder().decode([TimelineEvent].self, from: data) {
            events = decoded
        }
        
        // Append new event
        let event = TimelineEvent(
            timestamp: Date(),
            appName: appName,
            healthBefore: healthBefore,
            healthAfter: healthAfter,
            cooldownStarted: cooldownStarted,
            eventType: eventType
        )
        events.append(event)
        
        // Keep only last 100 events
        if events.count > 100 {
            events = Array(events.suffix(100))
        }
        
        // Save
        if let encoded = try? JSONEncoder().encode(events) {
            defaults.set(encoded, forKey: "timelineEvents")
        }
    }
}
