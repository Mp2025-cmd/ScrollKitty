//
//  NightlyAI.swift
//  ScrollKitty
//
//  AI generator for nightly (11 PM) summary messages
//  Hybrid approach: @Generable for structure + post-processing validation
//

import Foundation
import FoundationModels

// MARK: - Generable Response Structure

@Generable(description: "ScrollKitty's nightly reflection on the day")
struct NightlyAIResponse {
    @Guide(description: "Exactly 2 sentences using the provided descriptions. No advice.")
    var message: String
}

// MARK: - Nightly AI Generator

struct NightlyAI {

    // MARK: - System Prompt (Simplified)
    
    private static let prompt = """
    You are ScrollKitty, a cat companion.

    Write EXACTLY 2 sentences.
    - Sentence 1: State the phone usage using phoneUse and limitStatus from [DATA].
    - Sentence 2: Express how you (the cat) feel using emotion from [DATA].

    Use the exact descriptions provided. No advice. No commands. Speak naturally.
    """

    // MARK: - Generation Options
    
    static let options = GenerationOptions(
        sampling: .random(top: 25),
        temperature: 0.5,
        maximumResponseTokens: 60
    )

    // MARK: - Prompt Building

    /// Builds the [DATA] block with pre-formatted descriptions
    static func buildPrompt(context: TerminalNightlyContext) -> String {
        // Pre-compute all descriptions (no model interpretation needed)
        let phoneUse = HoursFormatter.naturalLanguage(context.phoneUseHours)
        let limitStatus = LimitDescriptionBuilder.build(
            status: context.limitStatus,
            goalLabel: context.screenTimeGoalLabel,
            overByHours: context.overByHours,
            underByHours: context.underByHours
        )
        let emotion = EmotionMapper.nightlyEmotion(for: context.currentHealthBand)

        return """
        [DATA]
        phoneUse: \(phoneUse)
        limitStatus: \(limitStatus)
        emotion: \(emotion)
        """
    }

    // MARK: - Generation

    /// Generates a nightly summary with @Generable structure + validation
    static func generate(
        context: TerminalNightlyContext, 
        overrideOptions: GenerationOptions? = nil
    ) async throws -> String {
        let session = LanguageModelSession(instructions: prompt)
        let dataPrompt = buildPrompt(context: context)
        let opt = overrideOptions ?? options

        // Generate with @Generable structure
        let response = try await session.respond(to: dataPrompt, generating: NightlyAIResponse.self, options: opt)
        
        // Post-process: cleanup and enforce 2 sentences
        let cleaned = CatMessage(from: response.content.message).message

        // Validate output
        try OutputValidator.validateNightly(cleaned, context: context)
        
        return cleaned
    }
}
