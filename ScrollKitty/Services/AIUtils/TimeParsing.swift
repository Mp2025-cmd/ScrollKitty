//
//  TimeParsing.swift
//  ScrollKitty
//

import Foundation

enum TimeParsing {
    static func parseHours(from label: String?) -> Double? {
        guard let label else { return nil }
        let pattern = #"(\d+(\.\d+)?)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(label.startIndex..<label.endIndex, in: label)
        guard let match = regex.firstMatch(in: label, range: range),
              let r = Range(match.range(at: 1), in: label)
        else { return nil }
        return Double(label[r])
    }

    static func makeDerived(
        goalLabel: String?,
        phoneUseHours: Double?,
        goalMet: Bool?
    ) -> (goalHours: Double?, status: TerminalNightlyContext.LimitStatus, over: Double?, under: Double?) {
        let goalHours = parseHours(from: goalLabel)

        let status: TerminalNightlyContext.LimitStatus = {
            if let goalMet { return goalMet ? .within : .past }
            if let g = goalHours, let u = phoneUseHours { return (u <= g) ? .within : .past }
            return .unknown
        }()

        let over: Double? = {
            guard let g = goalHours, let u = phoneUseHours else { return nil }
            return max(0, u - g)
        }()

        let under: Double? = {
            guard let g = goalHours, let u = phoneUseHours else { return nil }
            return max(0, g - u)
        }()

        return (goalHours, status, over, under)
    }
}
