import ComposableArchitecture
import UIKit

struct HapticsClient: Sendable {
    var wordTick: @Sendable () async -> Void
}

@MainActor
private enum WordTickHaptics {
    static let generator = UIImpactFeedbackGenerator(style: .medium)
}

extension HapticsClient: DependencyKey {
    static let liveValue = Self(
        wordTick: {
            await MainActor.run {
                WordTickHaptics.generator.prepare()
                WordTickHaptics.generator.impactOccurred(intensity: 1.0)
            }
        }
    )

    static let testValue = Self(
        wordTick: { }
    )

    static let previewValue = testValue
}

extension DependencyValues {
    var haptics: HapticsClient {
        get { self[HapticsClient.self] }
        set { self[HapticsClient.self] = newValue }
    }
}
