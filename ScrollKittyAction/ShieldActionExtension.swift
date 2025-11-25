import ManagedSettings
import ManagedSettingsUI
import Foundation
import UserNotifications

// MARK: - App Health Data (Extension Copy)

struct AppHealthData: Codable, Equatable {
    let appBundleIdentifier: String
    var currentHP: Double
    let maxHP: Double
    var lastBypass: Date?
}

// MARK: - App Group Actor (Extension Copy)

actor AppGroupDefaults {
    private let suiteName = "group.com.scrollkitty.app"
    private var defaults: UserDefaults?

    init() {
        self.defaults = UserDefaults(suiteName: suiteName)
    }

    func loadAppHealthData() -> [String: AppHealthData] {
        guard let defaults = defaults,
              let data = defaults.data(forKey: "appHealthData"),
              let decoded = try? JSONDecoder().decode([String: AppHealthData].self, from: data) else {
            return [:]
        }
        return decoded
    }

    func saveAppHealthData(_ data: [String: AppHealthData]) {
        guard let defaults = defaults else { return }
        if let encoded = try? JSONEncoder().encode(data) {
            defaults.set(encoded, forKey: "appHealthData")
            defaults.synchronize()
        }
    }

    func calculateGlobalHealth() -> Double {
        let allAppHealth = loadAppHealthData()
        return allAppHealth.values.map { $0.currentHP }.reduce(0, +)
    }

    func calculateHealthPercentage() -> Double {
        let allAppHealth = loadAppHealthData()
        let totalMaxHP = allAppHealth.values.map { $0.maxHP }.reduce(0, +)
        guard totalMaxHP > 0 else { return 100.0 }
        let totalCurrentHP = allAppHealth.values.map { $0.currentHP }.reduce(0, +)
        return (totalCurrentHP / totalMaxHP) * 100.0
    }

    func deductHealthFromApp(bundleIdentifier: String, amount: Double) -> (appCurrentHP: Double, appMaxHP: Double, globalHP: Double, isDead: Bool) {
        var healthData = loadAppHealthData()

        guard var appHealth = healthData[bundleIdentifier] else {
            // App not found, return safe defaults
            return (0, 0, calculateGlobalHealth(), false)
        }

        appHealth.currentHP = max(0, appHealth.currentHP - amount)
        appHealth.lastBypass = Date()
        healthData[bundleIdentifier] = appHealth

        saveAppHealthData(healthData)

        let globalHP = calculateGlobalHealth()
        let percentage = calculateHealthPercentage()

        // Update global health percentage in UserDefaults
        defaults?.set(percentage, forKey: "catHealthPercentage")

        // Update cat stage
        let stage = getCatStage(for: percentage)
        defaults?.set(stage, forKey: "catStage")

        defaults?.synchronize()

        return (appHealth.currentHP, appHealth.maxHP, globalHP, globalHP <= 0)
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
}

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
            handleBypassForApp(application: application) {
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
                // Don't remove from shields - just save cooldown and close
                completionHandler(.close)
            }
        @unknown default:
            completionHandler(.close)
        }
    }
    
    // MARK: - Helpers

    private func handleBypassForApp(application: ApplicationToken, completion: @escaping () -> Void) {
        Task {
            // Use Base64 encoded token data as unique identifier
            guard let tokenData = try? JSONEncoder().encode(application) else {
                print("[ShieldAction] ❌ Failed to encode application token")
                completion()
                return
            }
            let tokenId = tokenData.base64EncodedString()

            let actor = AppGroupDefaults()
            let result = await actor.deductHealthFromApp(bundleIdentifier: tokenId, amount: 10.0)

            let (appCurrentHP, appMaxHP, globalHP, isDead) = result

            print("[ShieldAction] 📉 App token: \(tokenId)")
            print("[ShieldAction] 📉 Deducted 10 HP. App Health: \(appCurrentHP)/\(appMaxHP)")
            print("[ShieldAction] 📉 Global Cat Health: \(globalHP) HP")

            if isDead {
                print("[ShieldAction] ☠️ Cat is DEAD (Global HP = 0)")
            }

            // Schedule damage notification
            await scheduleDamageNotificationHP(
                appCurrentHP: appCurrentHP,
                appMaxHP: appMaxHP,
                globalHP: globalHP,
                isDead: isDead,
                bundleId: tokenId
            )

            // Save per-app cooldown expiration
            await setPerAppCooldown(bundleId: tokenId)

            // Record penalty timestamp
            let sharedDefaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
            sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "lastShieldPenalty")

            completion()
        }
    }

    // Fallback for categories/web domains (global HP deduction)
    private func handleBypass(completion: @escaping () -> Void) {
        Task {
            let actor = AppGroupDefaults()
            let healthData = await actor.loadAppHealthData()

            // Deduct 10 HP from first app as fallback
            if let firstAppId = healthData.keys.first {
                let result = await actor.deductHealthFromApp(bundleIdentifier: firstAppId, amount: 10.0)
                print("[ShieldAction] 📉 Fallback bypass: Deducted 10 HP from \(firstAppId)")

                let (_, _, globalHP, isDead) = result
                await scheduleDamageNotificationHP(
                    appCurrentHP: 0,
                    appMaxHP: 0,
                    globalHP: globalHP,
                    isDead: isDead,
                    bundleId: "general"
                )

                // Set cooldown for fallback too
                await setPerAppCooldown(bundleId: firstAppId)
            }

            completion()
        }
    }
    
    private func setPerAppCooldown(bundleId: String) async {
        let sharedDefaults = UserDefaults(suiteName: "group.com.scrollkitty.app")

        // Get Shield Interval (default 15 mins)
        let intervalMinutes = sharedDefaults?.integer(forKey: "shieldInterval") ?? 15
        let intervalSafe = intervalMinutes > 0 ? intervalMinutes : 15

        // Calculate expiration time
        let expiration = Date().addingTimeInterval(TimeInterval(intervalSafe * 60))

        // Save per-app cooldown with app-specific key
        let cooldownKey = "cooldown_\(bundleId)"
        sharedDefaults?.set(expiration.timeIntervalSince1970, forKey: cooldownKey)
        sharedDefaults?.synchronize()

        print("[ShieldAction] ⏱️ Cooldown set for \(bundleId) until \(expiration)")

        // Schedule countdown notification
        await scheduleCooldownNotification(
            bundleId: bundleId,
            intervalMinutes: intervalSafe
        )
    }
    
    private func scheduleDamageNotificationHP(appCurrentHP: Double, appMaxHP: Double, globalHP: Double, isDead: Bool, bundleId: String) async {
        let content = UNMutableNotificationContent()
        content.title = "Scroll Kitty Hurt! 😿"

        if isDead {
            content.body = "You killed me... I'm gone until tomorrow. (Global HP = 0)"
        } else {
            let appName = bundleId.components(separatedBy: ".").last?.capitalized ?? "App"
            content.body = "Lost 10 HP. \(appName): \(Int(appCurrentHP))/\(Int(appMaxHP)) HP | Total: \(Int(globalHP)) HP"
        }

        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("[ShieldAction] ⚠️ Failed to schedule notification: \(error)")
        }
    }
    
    private func scheduleCooldownNotification(bundleId: String, intervalMinutes: Int) async {
        let appName = bundleId.components(separatedBy: ".").last?.capitalized ?? "App"

        let content = UNMutableNotificationContent()
        content.title = "\(appName) Unlocked"
        content.body = "Unblocked for \(intervalMinutes) minutes. Shield will return automatically."
        content.sound = .default

        // Auto-dismiss after 5 seconds (ScreenZen style)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(
            identifier: "cooldown_\(bundleId)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("[ShieldAction] 🔔 Cooldown notification scheduled for \(appName)")
        } catch {
            print("[ShieldAction] ⚠️ Failed to schedule cooldown notification: \(error)")
        }
    }
}

