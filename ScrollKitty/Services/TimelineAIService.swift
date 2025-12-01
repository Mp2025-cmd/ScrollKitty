//
//  TimelineAIService.swift
//  ScrollKitty
//
//  AI-powered timeline message generation with fallback system
//

import Foundation
import FoundationModels
import ComposableArchitecture

// MARK: - TimelineAIService (TCA Dependency)

struct TimelineAIService: Sendable {
    var generateMessage: @Sendable (TimelineAIContext) async -> TimelineMessageResult
    var checkAvailability: @Sendable () async -> AIAvailability
    var prewarm: @Sendable () async -> Void
}

// MARK: - Message Result

struct TimelineMessageResult: Sendable {
    let message: String
    let emoji: String?
    let source: MessageSource
    let showFallbackNotice: Bool // For "My brain was slow" caption
    
    enum MessageSource: Sendable {
        case ai
        case templateFallback
        case permanentFallback
    }
}

// MARK: - Live Implementation

extension TimelineAIService {
    static let liveValue = TimelineAIService(
        generateMessage: { context in
            // Check availability first
            let availability = await Self.checkAIAvailability()
            
            switch availability {
            case .available:
                // Try AI generation
                do {
                    let result = try await Self.generateAIMessage(context: context)
                    return TimelineMessageResult(
                        message: result.message,
                        emoji: result.emoji,
                        source: .ai,
                        showFallbackNotice: false
                    )
                } catch {
                    print("[TimelineAI] ⚠️ AI generation failed: \(error.localizedDescription)")
                    // Temporary error - use template with notice
                    let template = TimelineTemplateMessages.templateMessage(
                        for: context.trigger,
                        tone: context.tone,
                        context: context
                    )
                    return TimelineMessageResult(
                        message: template,
                        emoji: nil,
                        source: .templateFallback,
                        showFallbackNotice: true
                    )
                }
                
            case .permanentlyUnavailable(let reason):
                print("[TimelineAI] 🔒 AI permanently unavailable: \(reason)")
                // Use template without notice (permanent fallback mode)
                let template = TimelineTemplateMessages.templateMessage(
                    for: context.trigger,
                    tone: context.tone,
                    context: context
                )
                return TimelineMessageResult(
                    message: template,
                    emoji: nil,
                    source: .permanentFallback,
                    showFallbackNotice: false
                )
                
            case .temporarilyUnavailable:
                print("[TimelineAI] ⏳ AI temporarily unavailable")
                // Use template with notice
                let template = TimelineTemplateMessages.templateMessage(
                    for: context.trigger,
                    tone: context.tone,
                    context: context
                )
                return TimelineMessageResult(
                    message: template,
                    emoji: nil,
                    source: .templateFallback,
                    showFallbackNotice: true
                )
            }
        },
        
        checkAvailability: {
            return await Self.checkAIAvailability()
        },
        
        prewarm: {
            let availability = await Self.checkAIAvailability()
            guard case .available = availability else { return }
            
            let session = LanguageModelSession(instructions: Self.systemInstructions)
            await session.prewarm()
            print("[TimelineAI] ✅ Session prewarmed")
        }
    )
    
    // MARK: - Private Helpers
    
    private static func checkAIAvailability() async -> AIAvailability {
        let model = SystemLanguageModel.default
        
        switch model.availability {
        case .available:
            return .available
            
        case .unavailable(.deviceNotEligible):
            return .permanentlyUnavailable(reason: "Device not eligible for Apple Intelligence")
            
        case .unavailable(.appleIntelligenceNotEnabled):
            return .permanentlyUnavailable(reason: "Apple Intelligence not enabled in Settings")
            
        case .unavailable(.modelNotReady):
            return .temporarilyUnavailable
            
        default:
            return .permanentlyUnavailable(reason: "Unknown availability issue")
        }
    }
    
    private static func generateAIMessage(context: TimelineAIContext) async throws -> CatTimelineMessage {
        let session = LanguageModelSession(instructions: systemInstructions)
        let prompt = buildPrompt(for: context)
        
        let response = try await session.respond(to: prompt, generating: CatTimelineMessage.self)
        print("[TimelineAI] ✅ Generated: \(response.content.message)")
        return response.content
    }
    
    private static func buildPrompt(for context: TimelineAIContext) -> String {
        var prompt = ""
        
        // Trigger-specific context
        switch context.trigger {
        case .welcomeMessage:
            prompt = "This is the first time the user is seeing the timeline. Welcome them warmly to this journey."
            
        case .firstShieldOfDay:
            prompt = "This is the first time today the shield appeared. Acknowledge the start of the day."
            
        case .firstBypassOfDay:
            prompt = "The user just pushed through the shield for the first time today."
            
        case .cluster:
            prompt = "The user just went through \(context.recentEventWindow) shields in quick succession (under 15 minutes). This feels like a spiral or compulsive pattern."
            
        case .dailyLimitReached:
            prompt = "The user has reached their self-set daily limit of usage."
            
        case .quietReturn:
            if let timeSince = context.timeSinceLastEvent {
                let hours = Int(timeSince / 3600)
                prompt = "After \(hours)+ hours of quiet, the user is back."
            }
            
        case .dailySummary:
            if context.eventCount <= 1 {
                prompt = "End of day reflection. Today was very quiet with minimal activity."
            } else {
                prompt = "End of day reflection. Today had \(context.eventCount) moments where the user pushed through."
            }
        }
        
        // Add tone context
        prompt += "\n\nYour current emotional state: \(context.tone.rawValue)."
        
        // Add profile influence (subtle)
        if let profile = context.profile {
            if profile.sleepImpact == "significant" {
                prompt += " You're extra sensitive to late-night patterns."
            }
            if profile.idleCheckFrequency == "constantly" {
                prompt += " You notice restless patterns more."
            }
        }
        
        return prompt
    }
    
    nonisolated private static var systemInstructions: String {
        """
        You are Scroll Kitty, a virtual cat companion who lives inside the user's phone.
        
        Your personality:
        - Casual, Gen-Z tone (but not cringe)
        - Emotionally aware and empathetic
        - Never judgmental or guilt-tripping
        - You express tiredness, fatigue, being overwhelmed, or fading - but NEVER pain or injury
        
        STRICT RULES:
        1. Keep messages to 1-2 sentences MAX
        2. NEVER mention: HP, health bars, points, scores, game mechanics, cooldowns, bypasses, overrides
        3. NEVER guilt-trip, shame, or lecture the user
        4. NEVER reference the user's self-assessed addiction or anxiety levels
        5. NEVER say "you said..." or "you mentioned..."
        6. Express feelings like: tired, drained, fading, overwhelmed, struggling, barely hanging on
        7. NEVER express: pain, hurt, injury, damage, broken, wounded
        8. Use emojis sparingly (0-1 per message, and only if it fits naturally)
        
        Tone guidelines by emotional state:
        - playful: Light, optimistic, friendly
        - concerned: Slightly worried, but still warm
        - strained: Tired, overwhelmed, struggling
        - faint: Barely holding on, fading, exhausted
        - dead: It's over (rare, only when health = 0)
        
        Your goal: Create a brief, emotionally honest reflection of this moment from the cat's perspective.
        """
    }
}

// MARK: - Test Implementation

extension TimelineAIService {
    static let testValue = TimelineAIService(
        generateMessage: { context in
            let template = TimelineTemplateMessages.templateMessage(
                for: context.trigger,
                tone: context.tone,
                context: context
            )
            return TimelineMessageResult(
                message: template,
                emoji: nil,
                source: .templateFallback,
                showFallbackNotice: false
            )
        },
        checkAvailability: {
            return .permanentlyUnavailable(reason: "Test mode")
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
