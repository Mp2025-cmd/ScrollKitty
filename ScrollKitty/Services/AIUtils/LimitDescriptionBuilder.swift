//
//  LimitDescriptionBuilder.swift
//  ScrollKitty
//
//  Builds human-readable limit status descriptions
//  Pre-computed so the AI model receives ready-to-use text
//

import Foundation

enum LimitDescriptionBuilder {
    
    /// Builds a description of the user's limit status
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
    
    /// Builds a shorter limit phrase for terminal messages
    static func buildShort(
        status: TerminalNightlyContext.LimitStatus,
        overByHours: Double?
    ) -> String {
        
        switch status {
        case .within:
            return "within limit"
        case .past:
            if let over = overByHours, over > 0.1 {
                return "\(HoursFormatter.overByDescription(over)) over"
            }
            return "over limit"
        case .unknown:
            return ""
        }
    }
}

