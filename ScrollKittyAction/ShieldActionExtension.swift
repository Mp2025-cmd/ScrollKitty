import ManagedSettings
import ManagedSettingsUI
import Foundation
import UserNotifications

// Modern Shield Action API (iOS 16/17+)
class ShieldActionExtension: ShieldActionDelegate {
    
    // MARK: - Applications
    
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // "Close App"
            completionHandler(.close)
            
        case .secondaryButtonPressed:
            // "Ignore for 15m"
            penalizeCatHealth()
            updateStoreToAllow(application)
            completionHandler(.none)
            
        @unknown default:
            completionHandler(.close)
        }
    }
    
    // MARK: - Web Domains
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Web logic
        penalizeCatHealth()
        completionHandler(.none)
    }
    
    // MARK: - Categories
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Category logic
        penalizeCatHealth()
        updateStoreToAllow(category)
        completionHandler(.none)
    }
    
    // MARK: - Helpers
    
    private func penalizeCatHealth() {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.scrollkitty.app") else { return }
        
        let currentHealth = sharedDefaults.double(forKey: "catHealthPercentage")
        let newHealth = max(0, currentHealth - 10)
        
        sharedDefaults.set(newHealth, forKey: "catHealthPercentage")
        
        let stage = getCatStage(for: Int(newHealth))
        sharedDefaults.set(stage, forKey: "catStage")
        sharedDefaults.set(Date().timeIntervalSince1970, forKey: "lastShieldPenalty")
        
        print("[ShieldAction] 📉 Penalized health to \(newHealth)%")
        
        scheduleNotification(health: Int(newHealth))
    }
    
    private func updateStoreToAllow(_ token: ApplicationToken) {
        let store = ManagedSettingsStore()
        
        var shieldedApps = store.shield.applications ?? []
        shieldedApps.remove(token)
        store.shield.applications = shieldedApps
        
        let sharedDefaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
        let expiration = Date().addingTimeInterval(15 * 60)
        sharedDefaults?.set(expiration.timeIntervalSince1970, forKey: "unblockExpiration")
    }
    
    private func updateStoreToAllow(_ token: ActivityCategoryToken) {
        // Skip for MVP
    }
    
    private func getCatStage(for health: Int) -> String {
        switch health {
        case 80...100: return "healthy"
        case 60..<80: return "concerned"
        case 40..<60: return "tired"
        case 20..<40: return "sick"
        default: return "dead"
        }
    }
    
    private func scheduleNotification(health: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Scroll Kitty Hurt! 😿"
        content.body = "Unlocking the app cost 10 health. Current: \(health)%"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
