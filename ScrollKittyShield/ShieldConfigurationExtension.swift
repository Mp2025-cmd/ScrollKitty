import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    private func makeConfiguration() -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .dark,
            backgroundColor: UIColor(red: 0.0, green: 0.35, blue: 0.85, alpha: 1.0), // ScrollKitty Blue
            title: ShieldConfiguration.Label(text: "Scroll Kitty says NO!", color: .white),
            subtitle: ShieldConfiguration.Label(text: "Time to focus on something else.", color: .lightGray),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Close App", color: .white),
            primaryButtonBackgroundColor: .systemGray,
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Ignore for 15m (-10 Health)", color: .systemRed)
        )
    }
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        makeConfiguration()
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        makeConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration()
    }
}
