import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private let appGroupID = "group.com.scrollkitty.app"

    private enum ShieldState: String {
        case normal = "normal"
        case waitingForTap = "waitingForTap"
        case notificationResent = "notificationResent"
    }

    private func getShieldState() -> ShieldState {
        let defaults = UserDefaults(suiteName: appGroupID)
        let stateRaw = defaults?.string(forKey: "shieldState") ?? "normal"
        return ShieldState(rawValue: stateRaw) ?? .normal
    }

    private func getHealth() -> Int {
        let defaults = UserDefaults(suiteName: appGroupID)
        let health = defaults?.integer(forKey: "catHealth") ?? 100
        return health  // Return actual value including 0 (dead state)
    }
    
    private func makeAliveConfiguration(appName: String) -> ShieldConfiguration {
        let catImage = UIImage(named: "1_Healthy_Cheerful")
        let state = getShieldState()

        let backgroundColor = UIColor(red: 0.0, green: 0.35, blue: 0.85, alpha: 1.0) // ScrollKitty Blue
        let primaryButtonBgColor = UIColor(red: 0.0, green: 0.75, blue: 0.3, alpha: 1.0) // Green

        switch state {
        case .normal:
            return ShieldConfiguration(
                backgroundBlurStyle: .dark,
                backgroundColor: .clear,
                icon: catImage,
                title: ShieldConfiguration.Label(text: "Before you open \(appName)…", color: .white),
                subtitle: ShieldConfiguration.Label(text: "ScrollKitty wants a moment.", color: .white),
                primaryButtonLabel: ShieldConfiguration.Label(text: "Step back", color: .white),
                primaryButtonBackgroundColor: primaryButtonBgColor,
                secondaryButtonLabel: ShieldConfiguration.Label(text: "Go in anyway", color: .systemRed)
            )

        case .waitingForTap:
            return ShieldConfiguration(
                backgroundBlurStyle: .dark,
                backgroundColor: .clear,
                icon: catImage,
                title: ShieldConfiguration.Label(text: "ScrollKitty wants to talk", color: .white),
                subtitle: ShieldConfiguration.Label(text: "I sent you a tap so we can talk together.", color: .white),
                primaryButtonLabel: ShieldConfiguration.Label(text: "Didn't see it?", color: .white),
                primaryButtonBackgroundColor: primaryButtonBgColor,
                secondaryButtonLabel: nil
            )

        case .notificationResent:
            return ShieldConfiguration(
                backgroundBlurStyle: .dark,
                backgroundColor: .clear,
                icon: catImage,
                title: ShieldConfiguration.Label(text: "Notification sent again", color: .white),
                subtitle: ShieldConfiguration.Label(text: "Make sure you are not in Do not disturb mode", color: .white),
                primaryButtonLabel: ShieldConfiguration.Label(text: "Send again", color: .white),
                primaryButtonBackgroundColor: primaryButtonBgColor,
                secondaryButtonLabel: nil
            )
        }
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
        let appName = application.localizedDisplayName ?? "this app"
        return getHealth() <= 0 ? makeDeadConfiguration() : makeAliveConfiguration(appName: appName)
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        let appName = application.localizedDisplayName ?? "this app"
        return getHealth() <= 0 ? makeDeadConfiguration() : makeAliveConfiguration(appName: appName)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // WebDomain doesn't have localizedDisplayName, so use a generic name
        return getHealth() <= 0 ? makeDeadConfiguration() : makeAliveConfiguration(appName: "this site")
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // WebDomain doesn't have localizedDisplayName, so use a generic name
        return getHealth() <= 0 ? makeDeadConfiguration() : makeAliveConfiguration(appName: "this site")
    }
}
