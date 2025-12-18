//
//  TerminalNightlyContext.swift
//  ScrollKitty
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
    let firstUseTime: String?
    let lastUseTime: String?
    let phoneUseHours: String?
    let terminalAtLocalTime: String?
    let dayPart: DayPart
    let goalHours: Double?
    let limitStatus: LimitStatus
    let overByHours: String?
    let underByHours: String?
}
