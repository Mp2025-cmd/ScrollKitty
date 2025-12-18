//
//  NightlyAI.swift
//  ScrollKitty
//
//  PRESERVED: AI infrastructure for future shield dialogue feature.
//  Currently unused for Nightly summaries (replaced with templates in NightlyTerminalTemplates.swift).
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
        // Convert formatted strings back to numbers for AI prompt (preserved for future use)
        let phoneUseHours = formatHoursFromString(context.phoneUseHours)
        let limitHours = formatHours(context.goalHours)
        let overByHours = formatHoursFromString(context.overByHours)
        let emotion = EmotionMapper.nightlyEmotion(for: context.currentHealthBand)
        
        // Add style hints to encourage variety (using timestamp for randomness)
        let styleHints = [
            "Start with 'The screen...'",
            "Start with 'You clocked...'",
            "Start with 'Your phone use...'",
            "Start with 'You spent...'",
            "Be creative with the opening"
        ]
        let styleHint = styleHints[Int(Date().timeIntervalSince1970) % styleHints.count]

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
    
    private static func formatHoursFromString(_ hoursString: String?) -> String {
        // For preserved AI code: convert formatted string back to simple number format
        // This is a simplified parser - assumes format like "3 hours 30 minutes" or "1 hour"
        guard let str = hoursString, str != "unknown" else { return "unknown" }
        // Extract first number as hours (simplified - for future AI use)
        if let match = str.range(of: #"(\d+)\s*hour"#, options: .regularExpression) {
            let hourStr = String(str[match])
            if let hour = Int(hourStr.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                return "\(hour)"
            }
        }
        return str
    }

    static func generate(
        context: TerminalNightlyContext,
        overrideOptions: GenerationOptions? = nil
    ) async throws -> String {
        let opt = overrideOptions ?? options
        let session = LanguageModelSession(instructions: prompt)

        let timestamp = Date().timeIntervalSince1970
        let dataPrompt = buildPrompt(context: context) + "\nGenerationID: \(Int(timestamp))"

        let response = try await session.respond(to: dataPrompt, generating: NightlyAIResponse.self, options: opt)
        return response.content.message
    }
}
