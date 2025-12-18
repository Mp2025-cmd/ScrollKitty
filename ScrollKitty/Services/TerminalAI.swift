//
//  TerminalAI.swift
//  ScrollKitty
//
//  PRESERVED: AI infrastructure for future shield dialogue feature.
//  Currently unused for Terminal summaries (replaced with templates in NightlyTerminalTemplates.swift).
//

import Foundation
import FoundationModels

@Generable(description: "ScrollKitty's terminal state message when completely drained")
struct TerminalAIResponse {
    @Guide(description: "Exactly 2 sentences. Use opener and closer from [DATA] exactly.")
    var message: String
}

struct TerminalAI {
    private static let prompt = """
    You are ScrollKitty, a tired cat companion.

    Write EXACTLY 2 sentences. Sample your response from a DIVERSE distribution of phrasings—avoid repeating the same structure each time.
    
    Sentence 1 — State the phone usage exceeded the limit. Include ALL THREE numbers from [DATA]: phoneUseHours, limitHours, overByHours.
    VARY your structure! Examples of DIFFERENT structures:
      • Subject-first: "You used your phone for X hours today, exceeding the Y-hour limit by Z hours."
      • Number-first: "X hours on your phone today—Z hours over the Y-hour limit."
      • Dramatic: "The screen lit up for X whole hours, blasting past your Y-hour cap by Z."
      • Casual: "So... X hours of scrolling, Y-hour limit, Z hours over. Oops."
      • Factual: "Phone time: X hours. Daily limit: Y hours. Overage: Z hours."
    
    Sentence 2 — Express exhaustion. Be creative but pick a mood from [DATA].closerOptions.
    
    RULES:
    - Use EXACT numbers (no "around", no "about", no rounding)
    - Never mention "health", "HP", or "zero"
    - No advice to the user
    - IMPORTANT: Vary sentence structure—don't always start with "You used"
    """

    static let options = GenerationOptions(
        sampling: .random(probabilityThreshold: 0.95, seed: nil),
        temperature: 1.0,
        maximumResponseTokens: 80
    )

    static func buildPrompt(context: TerminalNightlyContext) -> String {
        // Convert formatted strings back to numbers for AI prompt (preserved for future use)
        let phoneUseHours = formatHoursFromString(context.phoneUseHours)
        let limitHours = formatHours(context.goalHours)
        let overByHours = formatHoursFromString(context.overByHours)

        let closerOptions = [
            "I'm completely drained and couldn't go on.",
            "That was more than I could handle.",
            "I'm exhausted and done for the day.",
            "I couldn't keep up anymore.",
            "I'm wiped out and need to rest.",
            "That pushed me past my limits.",
            "I'm running on empty now.",
            "I gave everything I had and it wasn't enough."
        ]

        // Add variation hint for diversity (using timestamp for randomness)
        let hints = ["vary structure", "be creative", "use different phrasing", "change it up", "new approach"]
        let variationHint = hints[Int(Date().timeIntervalSince1970) % hints.count]
        
        return """
        [DATA]
        phoneUseHours: \(phoneUseHours)
        limitHours: \(limitHours)
        overByHours: \(overByHours)
        closerOptions: \(closerOptions.joined(separator: " | "))
        styleHint: \(variationHint)
        
        Note: Generate a fresh response. Instruction: \(variationHint) compared to previous outputs.
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

        let response = try await session.respond(to: dataPrompt, generating: TerminalAIResponse.self, options: opt)
        return response.content.message
    }
}
