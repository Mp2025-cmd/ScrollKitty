import Foundation

/// Service for selecting template messages in the shield bypass flow.
/// Provides random message selection from HealthBasedMessages and HealthBasedLimitMessages.
struct ShieldBypassMessageService {

    /// Returns a redirect message based on current health.
    /// Health deterministically maps to a band, then randomly selects from that band's messages.
    func getRedirectMessage(for health: Int) -> String {
        let messages = HealthBasedMessages.messages(forHealth: health)
        return messages.randomElement() ?? "Hey. Let's pause for a second."
    }

    /// Returns a pain-line acknowledgment message based on selected minutes.
    /// Message selection is purely time-based, independent of health state.
    func getPainLineMessage(for health: Int, minutes: Int) -> String {
        let messages = HealthBasedLimitMessages.messages(forMinutes: minutes)
        return messages.randomElement() ?? "Okay. \(minutes) minutes."
    }

    /// Returns the allowed time options (in minutes) based on current health.
    /// Implements health-gated time restrictions:
    /// - Band 3 (Healthy 80-100): [5, 10, 15, 30]
    /// - Band 2 (Worn 60-79): [5, 10, 15]
    /// - Band 1 (Struggling 40-59): [5, 10]
    /// - Band 0 (Critical 0-39): [5]
    func getAllowedTimes(for health: Int) -> [Int] {
        let band = HealthBasedMessages.band(for: health)

        switch band {
        case .healthy:
            return BypassTimeOption.allMinutes  // [5, 10, 15, 30]
        case .worn:
            return [5, 10, 15]
        case .struggling:
            return [5, 10]
        case .critical:
            return [5]
        }
    }

    /// Returns the smallest allowed time for the given health (recommended default).
    func getSmallestAllowedTime(for health: Int) -> Int {
        return getAllowedTimes(for: health).first ?? 5
    }
}

// MARK: - Dependency

import ComposableArchitecture

extension ShieldBypassMessageService: DependencyKey {
    static let liveValue = ShieldBypassMessageService()
    static let testValue = ShieldBypassMessageService()
    static let previewValue = ShieldBypassMessageService()
}

extension DependencyValues {
    var bypassMessageService: ShieldBypassMessageService {
        get { self[ShieldBypassMessageService.self] }
        set { self[ShieldBypassMessageService.self] = newValue }
    }
}
