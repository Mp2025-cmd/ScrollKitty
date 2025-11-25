import ManagedSettings
import ManagedSettingsUI
import UIKit

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

    func calculateGlobalHealth() -> Double {
        let allAppHealth = loadAppHealthData()
        return allAppHealth.values.map { $0.currentHP }.reduce(0, +)
    }

    func getAppHealth(bundleIdentifier: String) -> AppHealthData? {
        let healthData = loadAppHealthData()
        return healthData[bundleIdentifier]
    }
}

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private func loadAppHealthDataSync() -> [String: AppHealthData] {
        let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
        guard let data = defaults?.data(forKey: "appHealthData"),
              let decoded = try? JSONDecoder().decode([String: AppHealthData].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func getAppHealthStatus(bundleIdentifier: String?) -> (appCurrentHP: Double, appMaxHP: Double, globalHP: Double, isDead: Bool) {
        let healthData = loadAppHealthDataSync()
        let globalHP = healthData.values.map { $0.currentHP }.reduce(0, +)

        guard let bundleId = bundleIdentifier,
              let appHealth = healthData[bundleId] else {
            // Fallback if app not found
            return (0, 0, globalHP, globalHP <= 0)
        }

        return (appHealth.currentHP, appHealth.maxHP, globalHP, globalHP <= 0)
    }

    private func isInCooldown(bundleIdentifier: String?) -> Bool {
        guard let bundleId = bundleIdentifier else { return false }

        let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
        let cooldownKey = "cooldown_\(bundleId)"
        let expirationTimestamp = defaults?.double(forKey: cooldownKey) ?? 0

        guard expirationTimestamp > 0 else { return false }

        let now = Date().timeIntervalSince1970
        let inCooldown = now < expirationTimestamp

        if inCooldown {
            let remaining = Int(expirationTimestamp - now)
            print("[ShieldConfig] ⏱️ \(bundleId) in cooldown. \(remaining)s remaining")
        }

        return inCooldown
    }

    private func makeAliveConfiguration(appCurrentHP: Double, appMaxHP: Double, globalHP: Double, bundleId: String?) -> ShieldConfiguration {
        let appName = bundleId?.components(separatedBy: ".").last?.capitalized ?? "App"
        let title = "It hurts when you open this..."
        let subtitle = "\(appName): \(Int(appCurrentHP))/\(Int(appMaxHP)) HP | Total: \(Int(globalHP)) HP\nThis will cost 10 HP from \(appName)."

        return ShieldConfiguration(
            backgroundBlurStyle: .dark,
            backgroundColor: UIColor(red: 0.0, green: 0.35, blue: 0.85, alpha: 1.0), // ScrollKitty Blue
            title: ShieldConfiguration.Label(text: title, color: .white),
            subtitle: ShieldConfiguration.Label(text: subtitle, color: .lightGray),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Step Back - Let Me Live", color: .white),
            primaryButtonBackgroundColor: UIColor(red: 0.0, green: 0.75, blue: 0.3, alpha: 1.0), // Greenish
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Continue - I'll Take It", color: .systemRed)
        )
    }
    
    private func makeDeadConfiguration() -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .dark,
            backgroundColor: UIColor(white: 0.1, alpha: 1.0), // Dark Grey/Black
            title: ShieldConfiguration.Label(text: "I'm gone until tomorrow...", color: .white),
            subtitle: ShieldConfiguration.Label(text: "Global Cat Health reached 0 HP. All apps locked.", color: .lightGray),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Close App", color: .white),
            primaryButtonBackgroundColor: .systemGray,
            secondaryButtonLabel: nil // No bypass button
        )
    }

    private func makeCooldownConfiguration() -> ShieldConfiguration {
        // Minimal transparent config that auto-closes
        // By returning a simple config with .close action, the shield dismisses immediately
        ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: UIColor.clear,
            title: ShieldConfiguration.Label(text: "", color: .clear),
            subtitle: ShieldConfiguration.Label(text: "", color: .clear),
            primaryButtonLabel: nil,
            secondaryButtonLabel: nil
        )
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Use Base64 encoded token data as unique identifier
        var tokenId = "unknown"
        if let token = application.token, let data = try? JSONEncoder().encode(token) {
            tokenId = data.base64EncodedString()
        }

        // Check cooldown FIRST - if in cooldown, return transparent shield that auto-closes
        if isInCooldown(bundleIdentifier: tokenId) {
            return makeCooldownConfiguration()
        }

        // Normal shield logic after cooldown expired
        let status = getAppHealthStatus(bundleIdentifier: tokenId)

        if status.isDead {
            return makeDeadConfiguration()
        } else {
            return makeAliveConfiguration(
                appCurrentHP: status.appCurrentHP,
                appMaxHP: status.appMaxHP,
                globalHP: status.globalHP,
                bundleId: tokenId
            )
        }
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        var tokenId = "unknown"
        if let token = application.token, let data = try? JSONEncoder().encode(token) {
            tokenId = data.base64EncodedString()
        }

        // Check cooldown FIRST
        if isInCooldown(bundleIdentifier: tokenId) {
            return makeCooldownConfiguration()
        }

        // Normal shield logic after cooldown expired
        let status = getAppHealthStatus(bundleIdentifier: tokenId)

        if status.isDead {
            return makeDeadConfiguration()
        } else {
            return makeAliveConfiguration(
                appCurrentHP: status.appCurrentHP,
                appMaxHP: status.appMaxHP,
                globalHP: status.globalHP,
                bundleId: tokenId
            )
        }
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Web domains don't have bundle IDs, use general health
        // Note: Cooldown doesn't apply to web domains (they use fallback in ShieldActionExtension)
        let status = getAppHealthStatus(bundleIdentifier: nil)

        if status.isDead {
            return makeDeadConfiguration()
        } else {
            return makeAliveConfiguration(
                appCurrentHP: 0,
                appMaxHP: 0,
                globalHP: status.globalHP,
                bundleId: nil
            )
        }
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Web domains don't have bundle IDs, use general health
        let status = getAppHealthStatus(bundleIdentifier: nil)

        if status.isDead {
            return makeDeadConfiguration()
        } else {
            return makeAliveConfiguration(
                appCurrentHP: 0,
                appMaxHP: 0,
                globalHP: status.globalHP,
                bundleId: nil
            )
        }
    }
}
