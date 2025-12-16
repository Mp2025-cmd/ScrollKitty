//
//  TerminalAI.swift
//  ScrollKitty
//
//  AI generator for terminal (HP=0) messages
//  Hybrid approach: @Generable for structure + post-processing validation
//

import Foundation
import FoundationModels

// MARK: - Generable Response Structure

@Generable(description: "ScrollKitty's terminal state message when completely drained")
struct TerminalAIResponse {
    @Guide(description: "Exactly 2 sentences. Use opener and closer from [DATA] exactly.")
    var message: String
}

// MARK: - Terminal AI Generator

struct TerminalAI {

    // MARK: - System Prompt (Simplified)
    
    private static let prompt = """
    You are ScrollKitty, completely drained.

    Write EXACTLY 2 sentences.
    - Sentence 1: Start with opener, then state phoneUse and overBy from [DATA].
    - Sentence 2: Use closer EXACTLY as provided.

    Never mention "health", "HP", or "zero". No advice. No commands.
    """

    // MARK: - Generation Options
    
    static let options = GenerationOptions(
        sampling: .random(top: 1),
        temperature: 0.0,
        maximumResponseTokens: 60
    )

    // MARK: - Prompt Building

    /// Builds the [DATA] block with pre-formatted descriptions
    static func buildPrompt(context: TerminalNightlyContext) -> String {
        // Pre-compute all descriptions
        let phoneUse = HoursFormatter.naturalLanguage(context.phoneUseHours)
        let overBy = LimitDescriptionBuilder.buildShort(
            status: context.limitStatus,
            overByHours: context.overByHours
        )

        // Pick variations based on seed
        let opener = TerminalVariations.pick(TerminalVariations.openers, seed: context.variationSeed)
        
        let isNight = (context.dayPart == .evening || context.dayPart == .night)
        let closer = isNight
            ? TerminalVariations.pick(TerminalVariations.closersNight, seed: context.variationSeed &+ 17)
            : TerminalVariations.pick(TerminalVariations.closersDay, seed: context.variationSeed &+ 17)

        return """
        [DATA]
        opener: \(opener)
        phoneUse: \(phoneUse)
        overBy: \(overBy)
        closer: \(closer)
        """
    }

    // MARK: - Generation

    /// Generates a terminal message with @Generable structure + validation
    static func generate(
        context: TerminalNightlyContext, 
        overrideOptions: GenerationOptions? = nil
    ) async throws -> String {
        let session = LanguageModelSession(instructions: prompt)
        let dataPrompt = buildPrompt(context: context)
        let opt = overrideOptions ?? options

        // Generate with @Generable structure
        let response = try await session.respond(to: dataPrompt, generating: TerminalAIResponse.self, options: opt)
        
        // Post-process: cleanup and enforce 2 sentences
        let cleaned = CatMessage(from: response.content.message).message

        // Validate output (includes banned word checks)
        try OutputValidator.validateTerminal(cleaned, context: context)
        
        return cleaned
    }
}
