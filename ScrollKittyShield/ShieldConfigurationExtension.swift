import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    private func getHealthStatus() -> (health: Double, cost: Int) {
        let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
        let health = defaults?.double(forKey: "catHealthPercentage") ?? 100.0
        let cost = defaults?.integer(forKey: "healthCostPerBypass") ?? 10
        return (health, cost)
    }
    
    private func makeAliveConfiguration(cost: Int) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .dark,
            backgroundColor: UIColor(red: 0.0, green: 0.35, blue: 0.85, alpha: 1.0), // ScrollKitty Blue
            title: ShieldConfiguration.Label(text: "It hurts when you open this...", color: .white),
            subtitle: ShieldConfiguration.Label(text: "Continuing will take \(cost) health from me.", color: .lightGray),
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
            subtitle: ShieldConfiguration.Label(text: "You used all your lives today.", color: .lightGray),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Close App", color: .white),
            primaryButtonBackgroundColor: .systemGray,
            secondaryButtonLabel: nil // No bypass button
        )
    }
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        let status = getHealthStatus()
        if status.health <= 0 {
            return makeDeadConfiguration()
        } else {
            return makeAliveConfiguration(cost: status.cost)
        }
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        let status = getHealthStatus()
        if status.health <= 0 {
            return makeDeadConfiguration()
        } else {
            return makeAliveConfiguration(cost: status.cost)
        }
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        let status = getHealthStatus()
        if status.health <= 0 {
            return makeDeadConfiguration()
        } else {
            return makeAliveConfiguration(cost: status.cost)
        }
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        let status = getHealthStatus()
        if status.health <= 0 {
            return makeDeadConfiguration()
        } else {
            return makeAliveConfiguration(cost: status.cost)
        }
    }
}
