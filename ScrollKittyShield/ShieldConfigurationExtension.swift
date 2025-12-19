import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    private let appGroupID = "group.com.scrollkitty.app"

    private func shieldHealthBand(_ health: Int) -> Int {
        switch health {
        case 80...100: return 3  // Healthy
        case 60...79:  return 2  // Worn
        case 40...59:  return 1  // Struggling
        default:       return 0  // Critical (0–39)
        }
    }

    private let shieldCaptions: [[String]] = [
        // Band 0: Critical (0–39 HP)
        ["Please… not this one.", "I don't have much left.", "I'm struggling right now."],
        // Band 1: Struggling (40–59 HP)
        ["I'm not doing so well.", "This one really hurts.", "I need a moment."],
        // Band 2: Worn (60–79 HP)
        ["That one stings.", "I'm getting tired.", "Can we pause?"],
        // Band 3: Healthy (80–100 HP)
        ["Hey… slow down.", "Hold up a second.", "Before you go in…"]
    ]

    private func getCaption(for band: Int) -> String {
        let safeBand = max(0, min(shieldCaptions.count - 1, band))
        let captions = shieldCaptions[safeBand]
        guard !captions.isEmpty else { return "" }

        let defaults = UserDefaults(suiteName: appGroupID)
        let key = "shieldCaption_band\(safeBand)"

        let lastIndex = defaults?.object(forKey: key) as? Int
        let currentIndex: Int
        if let lastIndex {
            currentIndex = (lastIndex + 1) % captions.count
        } else {
            currentIndex = 0
        }

        defaults?.set(currentIndex, forKey: key)
        return captions[currentIndex]
    }

    private func getCatImage(for band: Int) -> UIImage? {
        let imageName: String
        switch band {
        case 3: imageName = "1_Healthy_Cheerful"   // 80–100 HP
        case 2: imageName = "2_Concerned_Anxious"  // 60–79 HP
        case 1: imageName = "3_Tired_Low-Energy"   // 40–59 HP
        default: imageName = "4_Extremely_Sick"    // 0–39 HP
        }
        return UIImage(named: imageName)
    }
    
    private func getHealth() -> Int {
        let defaults = UserDefaults(suiteName: appGroupID)
        let health = defaults?.integer(forKey: "catHealth") ?? 100
        return health  // Return actual value including 0 (dead state)
    }
    
    private func makeAliveConfiguration() -> ShieldConfiguration {
        let health = getHealth()
        let band = shieldHealthBand(health)
        let caption = getCaption(for: band)
        let catImage = getCatImage(for: band)

        return ShieldConfiguration(
            backgroundBlurStyle: .dark,
            backgroundColor: UIColor(red: 0.0, green: 0.35, blue: 0.85, alpha: 1.0), // ScrollKitty Blue
            icon: catImage,
            title: ShieldConfiguration.Label(text: caption, color: .white),
            subtitle: nil,
            primaryButtonLabel: ShieldConfiguration.Label(text: "Step back", color: .white),
            primaryButtonBackgroundColor: UIColor(red: 0.0, green: 0.75, blue: 0.3, alpha: 1.0), // Green
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Continue anyway", color: .systemRed)
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
