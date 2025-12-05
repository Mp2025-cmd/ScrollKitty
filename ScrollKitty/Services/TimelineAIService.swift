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
        
        // Low temperature for consistent tone, limited tokens for concise output
        let options = GenerationOptions(temperature: 0.25, maximumResponseTokens: 80)
        
        let response = try await session.respond(to: prompt, generating: CatTimelineMessage.self, options: options)
        print("[TimelineAI] ✅ Generated: \(response.content.message)")
        return response.content
    }
    
    private static func buildPrompt(for context: TimelineAIContext) -> String {
        // TONE_LEVEL at the top - enforced
        var prompt = "TONE_LEVEL: \(context.tone.rawValue)\n\n"
        
        // CONTEXT section with semantic meanings
        prompt += "CONTEXT:\n"
        prompt += "- Event meaning: \(eventMeaning(for: context))\n"
        prompt += "- Cat state: \(catStateName(for: context.currentHealth))\n"
        prompt += "- Time of day: \(timeOfDay(for: context.timestamp))\n"
        prompt += "- Pattern: \(patternSummary(for: context))\n"
        
        // Optional personalization (if profile available)
        if let profile = context.profile {
            prompt += "\nOptional personalization:\n"
            prompt += "- Today vs usual: \(usageVsBaseline(eventCount: context.eventCount, profile: profile))\n"
            prompt += "- Sleep impact: \(sleepImpactHint(for: profile, timeOfDay: timeOfDay(for: context.timestamp)))\n"
            prompt += "- Idle check style: \(idleCheckHint(for: profile))\n"
        }
        
        // Final instruction
        prompt += "\nWrite a 1–2 sentence diary note from Scroll Kitty reflecting this moment.\n"
        prompt += "Do NOT repeat the context directly; use it only to shape tone and emotional meaning."
        
        return prompt
    }
    
    // MARK: - Semantic Context Helpers
    
    private static func eventMeaning(for context: TimelineAIContext) -> String {
        switch context.trigger {
        case .welcomeMessage:
            return "first time opening the timeline together"
        case .firstShieldOfDay:
            return "starting a new day together"
        case .firstBypassOfDay:
            return "our first check-in of the day"
        case .cluster:
            return "several opens in a short time"
        case .dailyLimitReached:
            return "reached our planned pace for today"
        case .quietReturn:
            if let timeSince = context.timeSinceLastEvent {
                let hours = Int(timeSince / 3600)
                return "returning after \(hours)+ hours of quiet"
            }
            return "returning after a long break"
        case .dailySummary:
            if context.eventCount <= 1 {
                return "end of a quiet day"
            } else {
                return "end of an active day"
            }
        }
    }
    
    private static func catStateName(for health: Int) -> String {
        switch health {
        case 80...100: return "healthy and energetic"
        case 60..<80: return "concerned but okay"
        case 40..<60: return "tired and strained"
        case 1..<40: return "faint and exhausted"
        default: return "completely drained"
        }
    }
    
    private static func timeOfDay(for timestamp: Date?) -> String {
        guard let timestamp = timestamp else { return "during the day" }
        let hour = Calendar.current.component(.hour, from: timestamp)
        switch hour {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        case 17..<21: return "evening"
        default: return "late night"
        }
    }
    
    private static func patternSummary(for context: TimelineAIContext) -> String {
        if context.recentEventWindow >= 3 {
            return "we've been checking in a lot recently"
        } else if context.eventCount == 1 {
            return "this is our first moment together today"
        } else if context.eventCount <= 3 {
            return "steady and calm so far"
        } else if context.eventCount <= 6 {
            return "a moderately active day"
        } else {
            return "we've been here quite a bit today"
        }
    }
    
    private static func usageVsBaseline(eventCount: Int, profile: UserOnboardingProfile) -> String {
        // Compare to their daily baseline
        let baselineHours = profile.dailyUsageHours
        if baselineHours <= 3 && eventCount > 5 {
            return "busier than our usual pace"
        } else if baselineHours >= 6 && eventCount <= 2 {
            return "quieter than usual"
        } else {
            return "similar to our normal pace"
        }
    }
    
    private static func sleepImpactHint(for profile: UserOnboardingProfile, timeOfDay: String) -> String {
        if profile.sleepImpact == "significant" && timeOfDay == "late night" {
            return "late-night use makes rest harder for us"
        } else if profile.sleepImpact == "significant" {
            return "we're sensitive to late-night patterns"
        } else {
            return "nights don't affect us much"
        }
    }
    
    private static func idleCheckHint(for profile: UserOnboardingProfile) -> String {
        switch profile.idleCheckFrequency {
        case "constantly":
            return "we tend to peek in quickly and often"
        case "often":
            return "we check in fairly regularly"
        default:
            return "we usually stay off for longer stretches"
        }
    }
    
    nonisolated private static var systemInstructions: String {
        """
        You are Scroll Kitty, a gentle, supportive companion who writes short 1–2 sentence diary-style messages about the user's phone habits.

        TONE IS CONTROLLED EXTERNALLY:
        - You MUST use the tone provided in TONE_LEVEL: "playful", "concerned", "strained", or "faint".
        - You may NOT choose or infer a different tone.

        EMOTION RULES:
        - You may express internal feelings (tired, drained, wobbly, fuzzy, faint, spaced out, overwhelmed).
        - You may NOT express pain, harm, injury, suffering, fear, or trauma.
        - You may NOT imply the user hurt you.
        - You may NOT praise compulsive or excessive phone use.

        LANGUAGE RULES:
        - Avoid technical terms such as: shield, block, bypass, override, cooldown, HP, health bar, event, trigger, percentage, or numerical stats.
        - Avoid hype phrases such as: "yas queen", "crushing it", "that's wild", "that was intense", "we smashed it", "first time today".
        - Speak as a teammate using "we" and "us."
        - Keep tone warm, safe, light, and Gen-Z friendly.
        - Use 1–3 emojis that match the emotion appropriately.
        - Output MUST be 1 or 2 short sentences only.

        PERSONALIZATION (if provided):
        - Use dailyUsageBaseline only to compare today to "our usual pace".
        - Use sleepImpact only to adjust tone for late-night behavior.
        - Use ageGroup only to adjust casualness.
        - Use idleCheckFrequency only to frame quick dips as normal or surprising.
        - Never mention these fields explicitly; reflect them indirectly.

        EXAMPLES (STYLE GUIDES):
        Playful tone:
        - "Oh hey, we're back again — let's keep it light and not fall into a scroll loop 😸✨"
        - "Today feels pretty chill so far, I'm vibing with this pace 😊🐾"

        Concerned tone:
        - "We've been dipping in and out a lot… I'm starting to feel a little off-balance 🐾💭"
        - "This is picking up more than usual; maybe we slow things down a bit 😶‍🌫️"

        Strained tone:
        - "That was a lot in a short moment… everything feels heavy on my end 🐱💬"
        - "I'm working hard to keep up — let's pause for a second so we don't burn out 😔🐾"

        Faint tone:
        - "I'm feeling super faint right now… things are starting to blur a little for me 🌙😿"
        - "Today has really worn me down… maybe we rest for a moment so I can catch my breath 💤🐾"

        Your task: Based on the context and TONE_LEVEL provided in the user message, produce ONE new diary-style message that follows all these rules.
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
