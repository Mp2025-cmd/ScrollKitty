import ManagedSettings
import ManagedSettingsUI
import Foundation
import UserNotifications
import FamilyControls
import DeviceActivity

// Modern Shield Action API (iOS 16/17+)
class ShieldActionExtension: ShieldActionDelegate {

    private let store = ManagedSettingsStore()
    private let activityCenter = DeviceActivityCenter()

    // MARK: - Applications
    
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // "Step Back" (Alive) or "Close App" (Dead)
            completionHandler(.close)
            
        case .secondaryButtonPressed:
            // "Continue - I'll Take It"
            handleBypass {
                self.updateStoreToAllow(application)
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
            handleBypass {
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
            handleBypass {
                self.updateStoreToAllow(category)
                completionHandler(.none)
            }
        @unknown default:
            completionHandler(.close)
        }
    }
    
    // MARK: - Helpers
    
    private func handleBypass(completion: () -> Void) {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.scrollkitty.app") else {
            completion()
            return
        }
        
        let currentHealth = sharedDefaults.double(forKey: "catHealthPercentage")
        // If already dead, do nothing (shouldn't happen if config is correct)
        if currentHealth <= 0 {
            completion()
            return
        }
        
        let cost = sharedDefaults.integer(forKey: "healthCostPerBypass")
        let penalty = cost > 0 ? Double(cost) : 10.0 // Default to 10 if not set
        
        let newHealth = currentHealth - penalty
        
        // Save new health
        sharedDefaults.set(newHealth, forKey: "catHealthPercentage")
        
        // Update stage
        let stage = getCatStage(for: newHealth)
        sharedDefaults.set(stage, forKey: "catStage")
        sharedDefaults.set(Date().timeIntervalSince1970, forKey: "lastShieldPenalty")
        
        print("[ShieldAction] 📉 Penalized health by \(penalty). New Health: \(newHealth)%")
        
        scheduleNotification(health: newHealth, penalty: Int(penalty))
        
        completion()
    }
    
    private func updateStoreToAllow(_ token: ApplicationToken) {
        // 1. Remove app from shield
        var shieldedApps = store.shield.applications ?? []
        shieldedApps.remove(token)
        store.shield.applications = shieldedApps

        // 2. Get cooldown duration from user settings (default 15 minutes)
        let sharedDefaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
        let cooldownMinutes = sharedDefaults?.integer(forKey: "shieldInterval") ?? 15

        // 3. Store expiration time
        let expiration = Date().addingTimeInterval(Double(cooldownMinutes * 60))
        sharedDefaults?.set(expiration.timeIntervalSince1970, forKey: "unblockExpiration")

        print("[ShieldAction] 🔓 Unblocked app for \(cooldownMinutes) minutes")

        // 4. Schedule re-shielding via DeviceActivitySchedule
        scheduleReshieldActivity(cooldownMinutes: cooldownMinutes)
    }

    private func updateStoreToAllow(_ token: ActivityCategoryToken) {
        // 1. Remove category from shield
        let shieldedCategories = store.shield.applicationCategories ?? .specific([], except: [])

        if case .specific(let categories, let except) = shieldedCategories {
            var newCategories = categories
            newCategories.remove(token)
            store.shield.applicationCategories = .specific(newCategories, except: except)
        }

        // 2. Get cooldown duration from user settings (default 15 minutes)
        let sharedDefaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
        let cooldownMinutes = sharedDefaults?.integer(forKey: "shieldInterval") ?? 15

        print("[ShieldAction] 🔓 Unblocked category for \(cooldownMinutes) minutes")

        // 3. Schedule re-shielding via DeviceActivitySchedule
        scheduleReshieldActivity(cooldownMinutes: cooldownMinutes)
    }

    // MARK: - Re-shielding via DeviceActivitySchedule

    private func scheduleReshieldActivity(cooldownMinutes: Int) {
        let calendar = Calendar.current
        let actualNow = Date()

        // Calculate end time (when cooldown expires and shield should return)
        let endTime = calendar.date(byAdding: .minute, value: cooldownMinutes, to: actualNow)!
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)

        // TRICK: DeviceActivitySchedule requires minimum 15-minute interval.
        // If cooldown < 15 min, shift intervalStart backwards to create a valid interval.
        // Since we're already "inside" the interval, intervalDidStart fires immediately,
        // and intervalDidEnd fires at our desired cooldown time.
        var startTime = actualNow
        if cooldownMinutes < 15 {
            let shiftBackMinutes = 15 - cooldownMinutes
            startTime = calendar.date(byAdding: .minute, value: -shiftBackMinutes, to: actualNow)!
        }
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: startComponents.hour, minute: startComponents.minute),
            intervalEnd: DateComponents(hour: endComponents.hour, minute: endComponents.minute),
            repeats: false
        )

        let activityName = DeviceActivityName("reshield_cooldown")

        // Stop any existing reshield schedule
        activityCenter.stopMonitoring([activityName])

        do {
            try activityCenter.startMonitoring(activityName, during: schedule)
            print("[ShieldAction] ⏰ Scheduled re-shield at \(endComponents.hour ?? 0):\(String(format: "%02d", endComponents.minute ?? 0)) (interval starts at \(startComponents.hour ?? 0):\(String(format: "%02d", startComponents.minute ?? 0)))")
        } catch {
            print("[ShieldAction] ❌ Failed to schedule re-shield: \(error)")
        }
    }
    
    private func getCatStage(for health: Double) -> String {
        switch health {
        case 80...100: return "healthy"
        case 60..<80: return "concerned"
        case 40..<60: return "tired"
        case 20..<40: return "sick"
        default: return "dead"
        }
    }
    
    private func scheduleNotification(health: Double, penalty: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Scroll Kitty Hurt! 😿"
        if health <= 0 {
            content.body = "You killed me... I'm gone until tomorrow."
        } else {
            content.body = "Unlocking cost \(penalty) health. Current: \(Int(health))%"
        }
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
