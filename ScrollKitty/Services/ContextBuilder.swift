//
//  ContextBuilder.swift
//  ScrollKitty
//

import Foundation

enum ContextBuilder {

    private static let appGroupID = "group.com.scrollkitty.app"

    static func make(
        trigger: TerminalNightlyContext.Trigger,
        healthBand: Int,
        goalLabel: String?,
        goalMet: Bool?
    ) -> TerminalNightlyContext {
        
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            return makeMinimal(trigger: trigger, healthBand: healthBand, goalLabel: goalLabel, goalMet: goalMet)
        }

        let cumulativeSeconds = defaults.double(forKey: "cumulativePhoneUseSeconds")
        let firstBypass = defaults.object(forKey: "firstBypassTime") as? Date
        let lastBypass = defaults.object(forKey: "lastBypassTime") as? Date

        let phoneUseHoursRaw = cumulativeSeconds > 0 ? cumulativeSeconds / 3600.0 : nil

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"

        let firstUseTime = firstBypass.map { timeFormatter.string(from: $0) }
        let lastUseTime = lastBypass.map { timeFormatter.string(from: $0) }

        let terminalAtLocalTime: String? = (trigger == .terminal) ? timeFormatter.string(from: Date()) : nil

        let derived = TimeParsing.makeDerived(
            goalLabel: goalLabel,
            phoneUseHours: phoneUseHoursRaw,
            goalMet: goalMet
        )

        let dayPart: TerminalNightlyContext.DayPart = {
            guard trigger == .terminal else { return .unknown }
            return DayPartDeriver.from(timeString: terminalAtLocalTime)
        }()

        // Format hour values as natural language strings
        let phoneUseHours = Format.hours(phoneUseHoursRaw)
        let overByHours = Format.hours(derived.over)
        let underByHours = Format.hours(derived.under)

        return TerminalNightlyContext(
            trigger: trigger,
            currentHealthBand: healthBand,
            firstUseTime: firstUseTime,
            lastUseTime: lastUseTime,
            phoneUseHours: phoneUseHours,
            terminalAtLocalTime: terminalAtLocalTime,
            dayPart: dayPart,
            goalHours: derived.goalHours,
            limitStatus: derived.status,
            overByHours: overByHours,
            underByHours: underByHours
        )
    }

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

        // Format hour values as natural language strings
        let overByHours = Format.hours(derived.over)
        let underByHours = Format.hours(derived.under)

        return TerminalNightlyContext(
            trigger: trigger,
            currentHealthBand: healthBand,
            firstUseTime: nil,
            lastUseTime: nil,
            phoneUseHours: nil,
            terminalAtLocalTime: nil,
            dayPart: .unknown,
            goalHours: derived.goalHours,
            limitStatus: derived.status,
            overByHours: overByHours,
            underByHours: underByHours
        )
    }
}
