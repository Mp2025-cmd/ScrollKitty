//
//  AIMessageHistory.swift
//  ScrollKitty
//
//  Persisted record of AI-generated messages for context and history
//

import Foundation

struct AIMessageHistory: Codable, Equatable, Sendable {
    let id: UUID
    let timestamp: Date
    let trigger: String           // "healthBandDrop", "dailySummary", "dailyWelcome", etc.
    let healthBand: Int           // 100, 90, 80... at time of generation
    let response: String          // What the cat said
    let emoji: String?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        trigger: String,
        healthBand: Int,
        response: String,
        emoji: String?
    ) {
        self.id = id
        self.timestamp = timestamp
        self.trigger = trigger
        self.healthBand = healthBand
        self.response = response
        self.emoji = emoji
    }
}
