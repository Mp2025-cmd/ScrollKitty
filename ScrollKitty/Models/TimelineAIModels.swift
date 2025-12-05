//
//  TimelineAIModels.swift
//  ScrollKitty
//
//  Models for AI-powered timeline message generation
//

import Foundation
import FoundationModels

// MARK: - AI Output Schema

@Generable(description: "A short, emotionally-aware message from Scroll Kitty's perspective")
struct CatTimelineMessage {
    @Guide(description: "The cat's message about this moment, 1-2 sentences max, casual Gen-Z tone")
    var message: String
    
    @Guide(description: "An optional emoji that fits the mood (single emoji only)")
    var emoji: String?
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
    case firstShieldOfDay
    case firstBypassOfDay
    case cluster              // 3+ bypasses in 15 min
    case dailyLimitReached    // Narrative milestone
    case quietReturn          // First event after 4+ hours
    case dailySummary         // End-of-day (9-10 PM)
    case welcomeMessage       // First-time timeline after onboarding
}

// MARK: - AI Context

struct TimelineAIContext: Sendable {
    let trigger: TimelineEntryTrigger
    let tone: CatTone
    let currentHealth: Int
    let eventCount: Int           // Today's total bypasses
    let recentEventWindow: Int    // Bypasses in last 15 min
    let timeSinceLastEvent: TimeInterval?
    let profile: UserOnboardingProfile?
    let timestamp: Date?          // Event timestamp for time-of-day context
    
    // Optional event-specific data
    let appName: String?
    let healthBefore: Int?
    let healthAfter: Int?
}

// MARK: - AI Availability State

enum AIAvailability: Sendable {
    case available
    case permanentlyUnavailable(reason: String)
    case temporarilyUnavailable
}
