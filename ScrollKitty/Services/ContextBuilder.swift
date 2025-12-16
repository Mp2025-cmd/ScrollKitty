//
//  ContextBuilder.swift
//  ScrollKitty
//
//  Builds enriched TerminalNightlyContext with session data and derived fields
//

import Foundation

enum ContextBuilder {
    
    private static let appGroupID = "group.com.scrollkitty.app"
    
    /// Creates an enriched TerminalNightlyContext with session data
    static func make(
        trigger: TerminalNightlyContext.Trigger,
        healthBand: Int,
        goalLabel: String?,
        goalMet: Bool?,
        baselineCmp: String? = nil
    ) -> TerminalNightlyContext {
        
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            // Fallback to minimal context if App Group unavailable
            return makeMinimal(trigger: trigger, healthBand: healthBand, goalLabel: goalLabel, goalMet: goalMet)
        }
        
        // Read session tracking data
        let cumulativeSeconds = defaults.double(forKey: "cumulativePhoneUseSeconds")
        let firstBypass = defaults.object(forKey: "firstBypassTime") as? Date
        let lastBypass = defaults.object(forKey: "lastBypassTime") as? Date
        
        // Convert cumulative seconds to hours
        let phoneUseHours = cumulativeSeconds > 0 ? cumulativeSeconds / 3600.0 : nil
        
        // Format times if available
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        
        let firstUseTime = firstBypass.map { timeFormatter.string(from: $0) }
        let lastUseTime = lastBypass.map { timeFormatter.string(from: $0) }
        
        // Terminal-specific: current time
        let terminalAtLocalTime: String? = (trigger == .terminal) ? timeFormatter.string(from: Date()) : nil
        
        // Compute derived fields
        let derived = TimeParsing.makeDerived(
            goalLabel: goalLabel,
            phoneUseHours: phoneUseHours,
            goalMet: goalMet
        )
        
        // Day part (terminal only)
        let dayPart: TerminalNightlyContext.DayPart = {
            guard trigger == .terminal else { return .unknown }
            return DayPartDeriver.from(timeString: terminalAtLocalTime)
        }()
        
        // Stable seed for terminal variation (nightly ignores it)
        let seedString = "\(trigger.rawValue)|hb=\(healthBand)|use=\(Format.hours(phoneUseHours) ?? "na")|goal=\(goalLabel ?? "na")|over=\(Format.hours(derived.over) ?? "na")|t=\(terminalAtLocalTime ?? "na")"
        let seed = StableHash.hash(seedString)
        
        return TerminalNightlyContext(
            trigger: trigger,
            currentHealthBand: healthBand,
            screenTimeGoalLabel: goalLabel,
            goalMet: goalMet,
            firstUseTime: firstUseTime,
            lastUseTime: lastUseTime,
            phoneUseHours: phoneUseHours,
            comparedToBaseline: baselineCmp,
            terminalAtLocalTime: terminalAtLocalTime,
            dayPart: dayPart,
            variationSeed: seed,
            goalHours: derived.goalHours,
            limitStatus: derived.status,
            overByHours: derived.over,
            underByHours: derived.under
        )
    }
    
    /// Fallback context with minimal data (used if App Group unavailable)
    private static func makeMinimal(
        trigger: TerminalNightlyContext.Trigger,
        healthBand: Int,
        goalLabel: String?,
        goalMet: Bool?
    ) -> TerminalNightlyContext {
        
        let derived = TimeParsing.makeDerived(
            goalLabel: goalLabel,
            phoneUseHours: nil,
            goalMet: goalMet
        )
        
        return TerminalNightlyContext(
            trigger: trigger,
            currentHealthBand: healthBand,
            screenTimeGoalLabel: goalLabel,
            goalMet: goalMet,
            firstUseTime: nil,
            lastUseTime: nil,
            phoneUseHours: nil,
            comparedToBaseline: nil,
            terminalAtLocalTime: nil,
            dayPart: .unknown,
            variationSeed: 0,
            goalHours: derived.goalHours,
            limitStatus: derived.status,
            overByHours: derived.over,
            underByHours: derived.under
        )
    }
}


