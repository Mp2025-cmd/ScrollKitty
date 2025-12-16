//
//  TerminalNightlyContext.swift
//  ScrollKitty
//
//  Context for terminal & nightly closing messages
//

import Foundation

struct TerminalNightlyContext: Sendable {
    enum Trigger: String, Sendable {
        case terminal
        case nightly
    }
    
    enum LimitStatus: String, Sendable {
        case within
        case past
        case unknown
    }
    
    enum DayPart: String, Sendable {
        case morning
        case afternoon
        case evening
        case night
        case unknown
    }

    let trigger: Trigger
    let currentHealthBand: Int

    // Raw inputs
    let screenTimeGoalLabel: String?
    let goalMet: Bool?
    let firstUseTime: String?
    let lastUseTime: String?
    let phoneUseHours: Double?
    let comparedToBaseline: String?

    // Terminal-only (safe to keep on the struct; we won't include in Nightly prompt)
    let terminalAtLocalTime: String?
    let dayPart: DayPart
    let variationSeed: Int

    // Derived
    let goalHours: Double?
    let limitStatus: LimitStatus
    let overByHours: Double?
    let underByHours: Double?
}
