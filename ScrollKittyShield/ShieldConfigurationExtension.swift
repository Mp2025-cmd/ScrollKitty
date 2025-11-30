import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    private let appGroupID = "group.com.scrollkitty.app"
    
    private func getHealth() -> Int {
        let defaults = UserDefaults(suiteName: appGroupID)
        let health = defaults?.integer(forKey: "catHealth") ?? 100
        return health > 0 ? health : 100
    }
    
    private func makeAliveConfiguration() -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .dark,
            backgroundColor: UIColor(red: 0.0, green: 0.35, blue: 0.85, alpha: 1.0), // ScrollKitty Blue
            title: ShieldConfiguration.Label(text: "It hurts when you open this...", color: .white),
            subtitle: ShieldConfiguration.Label(text: "Continuing will take 5 HP from me.", color: .lightGray),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Step Back - Let Me Live", color: .white),
            primaryButtonBackgroundColor: UIColor(red: 0.0, green: 0.75, blue: 0.3, alpha: 1.0), // Green
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Continue - I'll Take It", color: .systemRed)
        )
    }
    
    private func makeDeadConfiguration() -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .dark,
            backgroundColor: UIColor(white: 0.1, alpha: 1.0), // Dark Grey/Black
            title: ShieldConfiguration.Label(text: "I'm gone until tomorrow...", color: .white),
            subtitle: ShieldConfiguration.Label(text: "You used all your health today.", color: .lightGray),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Close App", color: .white),
            primaryButtonBackgroundColor: .systemGray,
            secondaryButtonLabel: nil // No bypass button when dead
        )
    }
    
    // MARK: - Configuration Methods
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return getHealth() <= 0 ? makeDeadConfiguration() : makeAliveConfiguration()
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return getHealth() <= 0 ? makeDeadConfiguration() : makeAliveConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return getHealth() <= 0 ? makeDeadConfiguration() : makeAliveConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return getHealth() <= 0 ? makeDeadConfiguration() : makeAliveConfiguration()
    }
}
