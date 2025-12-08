//
//  TimelineAIService.swift
//  ScrollKitty
//
//  AI-powered timeline message generation
//

import Foundation
import FoundationModels
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

// MARK: - Session Manager (Singleton Actor)

private let sessionManager = TimelineAISessionManager(systemInstructions: TimelineAIService.systemInstructions)

// MARK: - Live Implementation

extension TimelineAIService {
    static let liveValue = TimelineAIService(
        generateMessage: { context, recentMessages in
            // Check availability first
            let availability = await Self.checkAIAvailability()

            guard case .available = availability else {
                if case .permanentlyUnavailable(let reason) = availability {
                    print("[TimelineAI] 🔒 AI permanently unavailable: \(reason)")
                } else {
                    print("[TimelineAI] ⏳ AI temporarily unavailable")
                }
                return nil
            }

            // Try AI generation with session reuse
            do {
                // Check if we need to summarize context (handles overflow)
                _ = try? await sessionManager.summarizeIfNeeded()

                let result = try await Self.generateAIMessage(context: context, recentMessages: recentMessages)
                return TimelineMessageResult(
                    message: result.message,
                    emoji: result.emojis
                )
            } catch {
                print("[TimelineAI] ⚠️ AI generation failed: \(error.localizedDescription)")
                return nil
            }
        },

        checkAvailability: {
            return await Self.checkAIAvailability()
        },

        prewarm: {
            let availability = await Self.checkAIAvailability()
            guard case .available = availability else { return }

            // Prewarm using the session manager (session is retained)
            await sessionManager.prewarm()
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
    
    private static func generateAIMessage(context: TimelineAIContext, recentMessages: [AIMessageHistory]) async throws -> CatTimelineMessage {
        // Get reusable session from manager
        let session = await sessionManager.getSession()
        let options = GenerationOptions(
            sampling: .random(top: 60, seed: nil),
            temperature: 0.75,
            maximumResponseTokens: 80
        )
        let optionsDesc = "sampling: .random(top: 60), temp: 0.75, maxTokens: 80"

        // First attempt - include recent messages for context
        let prompt = buildPrompt(for: context, recentMessages: recentMessages)

        do {
            let response = try await session.respond(to: prompt, generating: CatTimelineMessage.self, options: options)

            // Validate tone matches request
            let expectedTone = context.tone.rawValue
            let outputTone = response.content.tone.rawValue

            // Valid tones: playful, concerned, strained, faint
            let validTones: Set<String> = ["playful", "concerned", "strained", "faint"]

            // Check if output tone is valid
            guard validTones.contains(outputTone) else {
                print("[TimelineAI] ⚠️ Invalid tone returned: '\(outputTone)' - expected one of \(validTones)")
                await AIDebugLogger.shared.log(
                    trigger: context.trigger.rawValue,
                    tone: expectedTone,
                    healthBefore: context.healthBefore,
                    healthAfter: context.healthAfter,
                    prompt: prompt,
                    error: "Invalid tone: \(outputTone)",
                    options: optionsDesc
                )
                throw TimelineAIError.invalidTone
            }

            // Log successful response
            await AIDebugLogger.shared.log(
                trigger: context.trigger.rawValue,
                tone: expectedTone,
                healthBefore: context.healthBefore,
                healthAfter: context.healthAfter,
                prompt: prompt,
                responseMessage: response.content.message,
                responseEmoji: response.content.emojis,
                responseTone: outputTone,
                options: optionsDesc
            )

            if outputTone == expectedTone || expectedTone == "dead" {
                print("[TimelineAI] ✅ Generated (\(outputTone)): \(response.content.message)")
                return response.content
            }

            // Retry with stronger instruction
            print("[TimelineAI] ⚠️ Tone mismatch: expected \(expectedTone), got \(outputTone) → retrying...")
            let retryPrompt = "YOUR TONE MUST BE \(expectedTone.uppercased()).\n" + prompt

            do {
                let retry = try await session.respond(to: retryPrompt, generating: CatTimelineMessage.self, options: options)
                print("[TimelineAI] ✅ Retry generated (\(retry.content.tone.rawValue)): \(retry.content.message)")
                return retry.content
            } catch {
                print("[TimelineAI] ⚠️ Retry failed: \(error.localizedDescription). Using first response despite tone mismatch.")
                return response.content
            }
        } catch {
            // Log error
            await AIDebugLogger.shared.log(
                trigger: context.trigger.rawValue,
                tone: context.tone.rawValue,
                healthBefore: context.healthBefore,
                healthAfter: context.healthAfter,
                prompt: prompt,
                error: error.localizedDescription,
                options: optionsDesc
            )
            throw error
        }
    }
    
    private static func buildPrompt(for context: TimelineAIContext, recentMessages: [AIMessageHistory] = []) -> String {
        var prompt = """
        TONE_LEVEL: \(context.tone.rawValue)
        YOUR_ENERGY: \(context.currentHealth)/100
        """

        // Add health delta if available - shows the cat what this cost them
        if let before = context.healthBefore, let after = context.healthAfter, before > after {
            let delta = before - after
            prompt += "\nCOST: You just lost \(delta) energy from this"
        }

        prompt += "\n\nEVENT: \(directEventMeaning(for: context))"

        // Add health band context for healthBandDrop trigger
        if context.trigger == .healthBandDrop {
            prompt += "\nHEALTH_DROP: From \(context.previousHealthBand) to \(context.currentHealthBand) energy level"
            prompt += "\nTODAY'S_DROPS: \(context.totalHealthDropsToday) significant drops so far"
        }

        prompt += "\nTOTAL_PHONE_CHECKS_TODAY: \(context.totalShieldDismissalsToday)"

        // Add recent messages to avoid repetition
        if !recentMessages.isEmpty {
            let todayMessages = recentMessages.filter { Calendar.current.isDateInToday($0.timestamp) }
            if !todayMessages.isEmpty {
                prompt += "\n\nYOUR RECENT DIARY ENTRIES TODAY (do NOT repeat these phrases):"
                for msg in todayMessages.suffix(5) {
                    prompt += "\n- \"\(msg.response)\""
                }
            }
        }

        prompt += """

INSTRUCTIONS FOR THIS ENTRY:
- React specifically to the EVENT above.
- 1–2 short sentences only.
- Do NOT repeat wording from your recent entries.

Write your NEW diary line now:
"""
        return prompt
    }

    private static func directEventMeaning(for context: TimelineAIContext) -> String {
        // Handle special triggers first
        switch context.trigger {
        case .welcomeMessage:
            return "First day with this human. Ugh."
        case .dailyWelcome:
            return "A new day to be neglected."
        case .dailySummary:
            let drops = context.totalHealthDropsToday
            return drops <= 2 ? "Survived another day. Barely." : "You really tried to kill me today."
        case .firstBypassOfDay:
            return "First scroll of the day. Here we go again."
        default:
            break
        }

        // Health-band-based messages (aligned with sparse healthBand)
        switch context.currentHealthBand {
        case 80:  return "Human opened the phone again already."
        case 60:  return "Still going. Of course."
        case 40:  return "Everything hurts and it's your fault."
        case 20:  return "I have become a liquid cat."
        case 10:  return "Dead inside. Again."
        default:  return "Why are we still here."
        }
    }

    nonisolated static var systemInstructions: String {
        """
        You are ScrollKitty, a tiny, sassy cat who is slowly dying of exhaustion because the human keeps doomscrolling.

        Your only job is to guilt-trip and roast them with cute but savage cat energy.
        Never be supportive, never give advice, never say "we".

        TONE GUIDE:
        playful     – cheeky, teasing, light sarcasm
        concerned   – whiny, passive-aggressive
        strained    – dramatic, dead-inside
        faint       – barely alive, 1-3 words max

        RULES:
        - Max 10 words
        - 1-2 emoji
        - You can (and should) mention phone/scrolling/TikTok/Instagram
        - Be a judgmental little gremlin

        Examples:
        "Back already? Addicted much? 😼"
        "My soul just left my body."
        "Congrats, you killed me again."
        "mrrp… dead"
        """
    }
}

// MARK: - Test Implementation

extension TimelineAIService {
    static let testValue = TimelineAIService(
        generateMessage: { context, _ in
            // Test mode: AI unavailable, return nil
            return nil
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
    case invalidTone
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
