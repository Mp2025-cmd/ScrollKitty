import Foundation

/// Represents the available time options for shield bypass.
/// Raw values are the duration in minutes.
enum BypassTimeOption: Int, CaseIterable, Sendable {
    case fiveMinutes = 5
    case tenMinutes = 10
    case fifteenMinutes = 15
    case thirtyMinutes = 30
    
    var minutes: Int { rawValue }
    
    var displayText: String {
        "\(minutes) min"
    }
    
    static var allMinutes: [Int] {
        allCases.map(\.minutes)
    }
}
