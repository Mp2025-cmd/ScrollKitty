//
//  TimelineAIModels.swift
//  ScrollKitty
//
//  Models for AI-powered timeline message generation
//

import Foundation
import FoundationModels

// MARK: - AI Output Schema

@Generable(description: "A short, emotionally-aware diary entry from Scroll Kitty's perspective")
struct CatTimelineMessage {
    @Guide(description: "Must match TONE_LEVEL: playful, concerned, strained, or faint")
    var tone: CatMessageTone

    @Guide(description: "1-2 sentence diary note using 'we/us' language")
    var message: String

    @Guide(description: "1-3 emojis matching the tone")
    var emojis: String
}

@Generable
enum CatMessageTone: String {
    case playful
    case concerned
    case strained
    case faint
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
    case firstBypassOfDay     // First bypass of the day (always triggers)
    case healthBandDrop       // Health crossed a 10-point boundary (100→90, 90→80, etc.)
    case dailySummary         // 11 PM or health reached 0
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
    /// Calculates sparse health bands for reduced trigger frequency (max 5-6 triggers per day)
    /// Silent from 100-81, then triggers at 80, 60, 40, 20, 10
    static func healthBand(_ health: Int) -> Int {
        switch health {
        case 81...:   return 100   // Silent until 80
        case 66...80: return 80
        case 46...65: return 60
        case 26...45: return 40
        case 11...25: return 20
        case 1...10:  return 10
        default:      return 0
        }
    }
}
