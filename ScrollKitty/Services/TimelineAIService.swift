//
//  TimelineAIService.swift
//  ScrollKitty
//
//  Template-based timeline message generation (AI infrastructure preserved for future use)
//

import Foundation
import ComposableArchitecture

// MARK: - TimelineAIService (TCA Dependency)

struct TimelineAIService: Sendable {
    var generateMessage: @Sendable (TimelineAIContext, [AIMessageHistory]) async -> TimelineMessageResult?
    var checkAvailability: @Sendable () async -> AIAvailability
    var prewarm: @Sendable () async -> Void
}

// MARK: - Message Result

struct TimelineMessageResult: Sendable {
    let message: String
    let emoji: String?
}

// MARK: - Live Implementation

extension TimelineAIService {
    static let liveValue = TimelineAIService(
        generateMessage: { context, recentMessages in
            // Select template message based on health band and trigger
            let message = TimelineTemplateMessages.selectMessage(
                forHealthBand: context.currentHealthBand,
                trigger: context.trigger,
                avoiding: recentMessages
            )

            // Return result (emoji already embedded in template messages)
            return TimelineMessageResult(message: message, emoji: nil)
        },

        checkAvailability: {
            // Templates always available
            return .available
        },

        prewarm: {
            // No-op for templates (AI prewarm preserved in infrastructure for future use)
        }
    )
}

// MARK: - Test Implementation

extension TimelineAIService {
    static let testValue = TimelineAIService(
        generateMessage: { context, recentMessages in
            // Test mode: Use same template logic as live
            let message = TimelineTemplateMessages.selectMessage(
                forHealthBand: context.currentHealthBand,
                trigger: context.trigger,
                avoiding: recentMessages
            )
            return TimelineMessageResult(message: message, emoji: nil)
        },
        checkAvailability: {
            return .available
        },
        prewarm: {}
    )
}

// MARK: - Errors

enum TimelineAIError: Error {
    case guardrailViolation
    case modelUnavailable
}

// MARK: - TCA Dependency Registration

extension TimelineAIService: DependencyKey {
    // liveValue is already defined in the main extension above
}

extension DependencyValues {
    var timelineAI: TimelineAIService {
        get { self[TimelineAIService.self] }
        set { self[TimelineAIService.self] = newValue }
    }
}
