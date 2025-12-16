//
//  LimitDescriptionBuilder.swift
//  ScrollKitty
//

import Foundation

enum LimitDescriptionBuilder {
    static func build(
        status: TerminalNightlyContext.LimitStatus,
        goalLabel: String?,
        overByHours: Double?,
        underByHours: Double?
    ) -> String {
        switch status {
        case .within:
            if let goal = goalLabel {
                return "staying within your \(goal) limit"
            }
            return "staying within your limit"

        case .past:
            if let over = overByHours, over > 0.1 {
                let overDesc = HoursFormatter.overByDescription(over)
                return "going over your limit by \(overDesc)"
            }
            return "going past your limit"

        case .unknown:
            return "using your phone today"
        }
    }

    static func buildShort(
        status: TerminalNightlyContext.LimitStatus,
        overByHours: Double?
    ) -> String {
        switch status {
        case .within:
            return "within your limit"
        case .past:
            if let over = overByHours, over > 0.1 {
                return "\(HoursFormatter.overByDescription(over)) over your limit"
            }
            return "over your limit"
        case .unknown:
            if let over = overByHours, over > 0.1 {
                return "\(HoursFormatter.overByDescription(over)) over"
            }
            return "past your usual amount"
        }
    }
}

