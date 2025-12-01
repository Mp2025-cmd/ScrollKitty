import Foundation

/// User's onboarding profile - used to tune AI tone (not content)
/// Safe fields only - no addiction/anxiety data
public struct UserOnboardingProfile: Codable, Equatable, Sendable {
    let dailyUsageHours: Double      // Baseline usage (tunes "surprise" level)
    let sleepImpact: String          // "none", "some", "significant" (softens late-night tone)
    let ageGroup: String             // "13-17", "18-24", "25-34", "35+" (adjusts vocabulary)
    let idleCheckFrequency: String   // "rarely", "sometimes", "often", "constantly" (tunes pacing awareness)
    
    public init(
        dailyUsageHours: Double,
        sleepImpact: String,
        ageGroup: String,
        idleCheckFrequency: String
    ) {
        self.dailyUsageHours = dailyUsageHours
        self.sleepImpact = sleepImpact
        self.ageGroup = ageGroup
        self.idleCheckFrequency = idleCheckFrequency
    }
}
