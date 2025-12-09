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
                    emoji: emojiForHealthBand(context.currentHealthBand)
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
        // Wait for session to be available (handles concurrent calls)
        let session = await sessionManager.waitForSession()
        // Balanced options: some variety while following examples
        let options = GenerationOptions(
            sampling: .random(top: 40, seed: nil),
            temperature: 0.5,
            maximumResponseTokens: 50
        )
        let optionsDesc = "sampling: .random(top: 40), temp: 0.5, maxTokens: 50"

        // First attempt - include recent messages for context
        let prompt = buildPrompt(for: context, recentMessages: recentMessages)

        print("[TimelineAI] 🚀 Starting generation...")
        print("[TimelineAI] Trigger: \(context.trigger.rawValue) | Tone: \(context.tone.rawValue)")
        print("[TimelineAI] Options: \(optionsDesc)")
        print("[TimelineAI] 📝 Prompt:\n\(prompt)")

        do {
            let response = try await session.respond(to: prompt, generating: CatTimelineMessage.self, options: options)
            print("[TimelineAI] 📦 Raw response received, parsing...")

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
                responseEmoji: emojiForHealthBand(context.currentHealthBand),
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
            // Log error with full details
            print("[TimelineAI] ❌ Generation failed!")
            print("[TimelineAI] Error type: \(type(of: error))")
            print("[TimelineAI] Error: \(error)")
            print("[TimelineAI] Localized: \(error.localizedDescription)")

            await AIDebugLogger.shared.log(
                trigger: context.trigger.rawValue,
                tone: context.tone.rawValue,
                healthBefore: context.healthBefore,
                healthAfter: context.healthAfter,
                prompt: prompt,
                error: "\(type(of: error)): \(error.localizedDescription)",
                options: optionsDesc
            )
            throw error
        }
    }
    
    private static func buildPrompt(for context: TimelineAIContext, recentMessages: [AIMessageHistory] = []) -> String {
        let previousHealth = context.healthBefore ?? 100
        let currentHealth = context.currentHealth
        
        var prompt = """
        TONE: \(context.tone.rawValue)
        ENERGY: \(previousHealth)→\(currentHealth)
        
        Context: \(eventContext(for: context))
        """
        
        // Add band info for health drops only
        if context.trigger == .healthBandDrop {
            let dropNumber = context.totalHealthDropsToday
            prompt += "\nBand: \(context.previousHealthBand)→\(context.currentHealthBand) (drop \(dropNumber) today)"
        }
        
        // Add recent messages to avoid repetition
        let todayMessages = recentMessages.filter { Calendar.current.isDateInToday($0.timestamp) }
        if !todayMessages.isEmpty {
            prompt += "\n\nRecent entries today:"
            for msg in todayMessages.suffix(3) {
                prompt += "\n- \"\(msg.response)\""
            }
        }
        
        prompt += "\n\nWrite how this feels:"
        
        return prompt
    }
    
    private static func eventContext(for context: TimelineAIContext) -> String {
        switch context.trigger {
        case .welcomeMessage:
            return "Beginning the diary together for the first time"
        case .dailyWelcome:
            return "A new day is starting"
        case .dailySummary:
            // Base summary context on final health to better reflect day's intensity
            let finalHealth = context.currentHealth
            switch finalHealth {
            case 81...: return "A calm day is ending"
            case 41...80: return "A day with some heavier stretches is ending"
            case 1...40: return "A day that felt intense is coming to a close"
            case 0: return "A day that pushed you to your limit is ending"
            default: return "A day is coming to a close"
            }
        case .firstBypassOfDay:
            return "Your body felt a small wobble in energy"
        case .healthBandDrop:
            // Describe body state based on current health band (sparse: 80, 60, 40, 20, 10)
            switch context.currentHealthBand {
            case 80:
                return "Your body feels a gentle dip in energy, softer and more tired than earlier"
            case 60:
                return "Your body is carrying noticeable strain now, like a soft weight settling in"
            case 40:
                return "Your body is moving through a heavy period, each step feeling slower"
            case 20:
                return "Your body feels very faint and worn out, most of your energy already spent"
            case 10:
                return "Your body is barely holding itself up, almost at the point of shutting down"
            default:
                return "Your body feels different than before, something inside has shifted"
            }
        }
    }

    private static func emojiForHealthBand(_ band: Int) -> String {
        switch band {
        case 80:  return "🌤"   // playful - light clouds
        case 60:  return "🌥"   // concerned - cloudier
        case 40:  return "🌧"   // strained - rain
        case 20:  return "🌑"   // faint - dark
        case 10:  return "🪦"   // nearly gone
        default:  return "✨"   // welcome/daily
        }
    }

    nonisolated static var systemInstructions: String {
        """
        You are ScrollKitty, a small cat companion whose energy mirrors the user's day.
        You write short diary notes about how shifts feel in your body—acknowledge the change, then describe how you feel compared to before.

        Example: "I felt a small shift. Still light, just moving a little slower than before."

        playful: "I'm feeling a tiny dip, but my paws still feel light. I'm curious how the rest of today will flow."
        concerned: "I'm slowing down a bit now, like the day is getting heavier. I'm still here, just moving softer."
        strained: "My whole body feels tired, like each step takes thought. I'm pushing through carefully."
        faint: "I'm running very low, like most of my spark has dimmed. Every moment feels slower."

        Never mention phones or scrolling. 1-2 sentences, about 20 words.
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
