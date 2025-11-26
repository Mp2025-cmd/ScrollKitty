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
        let store = ManagedSettingsStore()
        
        var shieldedApps = store.shield.applications ?? []
        shieldedApps.remove(token)
        store.shield.applications = shieldedApps
        
        let sharedDefaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
        let expiration = Date().addingTimeInterval(15 * 60) // 15 minutes default unblock window? PRD says "returns to app", effectively unblocking.
        sharedDefaults?.set(expiration.timeIntervalSince1970, forKey: "unblockExpiration")
    }
    
    private func updateStoreToAllow(_ token: ActivityCategoryToken) {
         let store = ManagedSettingsStore()
         
         let shieldedCategories = store.shield.applicationCategories ?? .specific([], except: [])
         
         if case .specific(let categories, let except) = shieldedCategories {
             var newCategories = categories
             newCategories.remove(token)
             store.shield.applicationCategories = .specific(newCategories, except: except)
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
