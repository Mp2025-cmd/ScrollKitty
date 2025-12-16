//
//  DayPartDeriver.swift
//  ScrollKitty
//

import Foundation

enum DayPartDeriver {
    static func from(timeString: String?) -> TerminalNightlyContext.DayPart {
        guard let raw = timeString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty
        else { return .unknown }

        let upper = raw.uppercased()
        if upper.contains("AM") { return .morning }

        let pattern = #"^\s*(\d{1,2}):(\d{2})\s*PM\s*$"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: upper, range: NSRange(upper.startIndex..<upper.endIndex, in: upper)),
           let hrRange = Range(match.range(at: 1), in: upper),
           let hour = Int(upper[hrRange]) {
            switch hour {
            case 12, 1, 2, 3, 4: return .afternoon
            case 5, 6, 7: return .evening
            default: return .night
            }
        }
        return .evening
    }
}
