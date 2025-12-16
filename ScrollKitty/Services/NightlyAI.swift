//
//  NightlyAI.swift
//  ScrollKitty
//
//  AI generator for nightly (11 PM) summary messages
//

import Foundation
import FoundationModels

@Generable(description: "ScrollKitty's nightly reflection on the day")
struct NightlyAIResponse {
    @Guide(description: "Exactly 2 sentences using the provided descriptions. No advice.")
    var message: String
}

struct NightlyAI {
    private static let prompt = """
    You are ScrollKitty, documenting the USER's phone usage like a diary.
    
    Write EXACTLY 2 SHORT sentences. Each sentence MUST end with a period.
    
    Sentence 1: Tell the USER about THEIR phone usage. Talk TO them using "You" or "Your".
    VARY YOUR PHRASING! Do NOT always start with "You used".
    
    IMPORTANT: Include phoneUseHours and limitHours. Only mention overByHours if they went OVER.
    
    Examples of varied starts:
    - "The screen lit up for 6 hours, surpassing your 4-hour limit by 2."
    - "You clocked 3 hours on your phone, staying within your 4-hour limit."
    - "Your phone usage hit 5 hours, going 1 hour over the 4-hour cap."
    - "You spent 2 hours scrolling, well under your 4-hour limit."
    - "The screen was active for 6 hours, blasting past your 4-hour cap by 2."
    
    Sentence 2: Express how the CAT feels. The cat uses "I" to talk about itself.
    Examples:
    - "I feel worn out and exhausted."
    - "I'm great and energized."
    - "That left me completely wiped out."
    
    CRITICAL RULES:
    - Sentence 1: About USER's phone usage → use "You/Your"
    - Sentence 2: About CAT's feelings → use "I/I'm"
    - Must be EXACTLY 2 sentences
    - NO technical jargon (no "GenerationID", "field", "variable")
    """

    static let options = GenerationOptions(
        sampling: .random(top: 50),
        temperature: 0.9,
        maximumResponseTokens: 80
    )

    static func buildPrompt(context: TerminalNightlyContext) -> String {
        let phoneUseHours = formatHours(context.phoneUseHours)
        let limitHours = formatHours(context.goalHours)
        let overByHours = formatHours(context.overByHours)
        let emotion = EmotionMapper.nightlyEmotion(for: context.currentHealthBand)
        
        // Add style hints to encourage variety (rotates through options)
        let styleHints = [
            "Start with 'The screen...'",
            "Start with 'You clocked...'",
            "Start with 'Your phone use...'",
            "Start with 'You spent...'",
            "Be creative with the opening"
        ]
        let styleHint = styleHints[abs(context.variationSeed) % styleHints.count]

        return """
        [DATA]
        phoneUseHours: \(phoneUseHours)
        limitHours: \(limitHours)
        overByHours: \(overByHours)
        emotion: \(emotion)
        styleHint: \(styleHint)
        """
    }

    private static func formatHours(_ hours: Double?) -> String {
        guard let h = hours else { return "unknown" }
        if h.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(h))"
        } else {
            return String(format: "%.1f", h)
        }
    }

    static func generate(
        context: TerminalNightlyContext, 
        overrideOptions: GenerationOptions? = nil
    ) async throws -> String {
        let opt = overrideOptions ?? options
        let maxRetries = 3
        var lastError: Error?

        for attempt in 1...maxRetries {
            let session = LanguageModelSession(instructions: prompt)

            let timestamp = Date().timeIntervalSince1970
            let dataPrompt = buildPrompt(context: context) + "\nGenerationID: \(Int(timestamp))_attempt\(attempt)"

            do {
                let response = try await session.respond(to: dataPrompt, generating: NightlyAIResponse.self, options: opt)
                let cleaned = CatMessage(from: response.content.message).message
                try OutputValidator.validateNightly(cleaned, context: context)
                return cleaned
            } catch {
                lastError = error
            }
        }

        throw lastError ?? ValidationError.notExactlyTwoSentences(found: 0)
    }
}
