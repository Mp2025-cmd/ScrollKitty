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

    enum DataCompleteness: String, Sendable {
        case low
        case medium
        case high
    }

    // Minimal payload for AI
    let trigger: Trigger
    let currentHealthBand: Int
    let totalShieldDismissalsToday: Int
    let totalHealthDropsToday: Int
    let screenTimeGoalLabel: String?
    let goalMet: Bool?
    let goalMetReason: String?
    let dataCompleteness: DataCompleteness
}
