//
//  TimelineAIModels.swift
//  ScrollKitty
//
//  PRESERVED: AI infrastructure for future shield dialogue feature.
//  Currently unused for Terminal/Nightly summaries (replaced with templates in NightlyTerminalTemplates.swift).
//  
//  This file contains:
//  - @Generable macro for structured AI output (CatTimelineMessage)
//  - CatTone enum for health-based tone mapping (may be used by health band drops)
//  - TimelineAIContext for passing data to AI generation
//  - AIAvailability for checking on-device AI capability
//

import Foundation
import FoundationModels

// MARK: - AI Output Schema

@Generable(description: "A cat's brief diary moment")
struct CatTimelineMessage {
    @Guide(description: "Two short sentences about your inner state, 15-25 words")
    var message: String
}

// MARK: - Tone Levels

enum CatTone: String, Sendable {
    case playful = "playful"       // 100-80 HP
    case concerned = "concerned"   // 79-60 HP
    case strained = "strained"     // 59-40 HP
    case faint = "faint"           // 39-1 HP
    case dead = "dead"             // 0 HP
}

// MARK: - Timeline Entry Triggers

enum TimelineEntryTrigger: String, Codable, Equatable, Sendable {
    case welcomeMessage       // First-time timeline after install (static)
    case dailyWelcome         // AI-generated daily welcome after midnight reset
    case healthBandDrop       // Health crossed a 10-point boundary (100→90, 90→80, etc.)
    case dailySummary         // 11 PM or health reached 0
    case terminal             // Health reached 0 - stark, final closing message
    case nightly              // 11 PM reflection (22:55-23:05 window)
}

// MARK: - AI Context

struct TimelineAIContext: Sendable {
    let trigger: TimelineEntryTrigger
    let tone: CatTone
    let currentHealth: Int
    let profile: UserOnboardingProfile?
    let timestamp: Date?
    let appName: String?
    let healthBefore: Int?
    let healthAfter: Int?

    // Health band context
    let currentHealthBand: Int          // The band user entered (90, 80, 70...)
    let previousHealthBand: Int         // The band user left (100, 90, 80...)
    let totalShieldDismissalsToday: Int
    let totalHealthDropsToday: Int      // Count of 10-point drops today
}

// MARK: - AI Availability State

enum AIAvailability: Sendable {
    case available
    case permanentlyUnavailable(reason: String)
    case temporarilyUnavailable
}

// MARK: - Health Band Helper

extension TimelineAIContext {
    /// Calculates health bands at 20-point intervals starting at 80 HP
    /// Triggers at: 80, 60, 40, 20, 10 (max 5 messages per day)
    /// Each trigger represents ~2 bypasses, providing meaningful check-ins without overwhelming
    static func healthBand(_ health: Int) -> Int {
        switch health {
        case 81...:   return 100  // 81-100 = "100 band" (silent until 80)
        case 61...80: return 80   // First message zone
        case 41...60: return 60   // Concerned zone
        case 21...40: return 40   // Strained zone
        case 11...20: return 20   // Faint zone
        case 1...10:  return 10   // Critical zone
        default:      return 0
        }
    }
}
