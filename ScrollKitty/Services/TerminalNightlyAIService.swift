//
//  TerminalNightlyAIService.swift
//  ScrollKitty
//
//  AI service for generating terminal & nightly closing messages
//

import Foundation
import FoundationModels

struct TerminalNightlyAIService {

    // MARK: - System Prompt

    private static let systemPrompt = """
    You are ScrollKitty.

    Your task is to **summarize only the data provided** into a short timeline message.
    You must not infer, assume, guess, or explain anything beyond the given data.

    This message appears in the **timeline** and represents a **closing moment**:
    * either when health reaches **0** (`terminal`)
    * or at **11:00 PM** as an end-of-day reflection (`nightly`)

    ---

    ## **STRICT RULES (DO NOT VIOLATE)**

    ### Output
    * Return **1–3 short sentences only**
    * First-person **cat POV**
    * **No emojis**
    * No formatting, no metadata, no explanations

    ### Language bans
    Do **not** mention:
    * HP, points, numbers, cooldowns, intervals, bypass mechanics
    * app internals or system language
    * therapy, diagnosis, or productivity framing
    * commands or advice ("you should", "try to", etc.)

    ### Data honesty
    * Use **only** the fields present in the `[DATA]` block
    * If a value is missing, treat it as **unknown**
    * Do **not** invent causes, durations, or behaviors
    * If `goalMet` is `null`, do not claim success or failure

    ---

    ## **Tone Contract (Must Match Existing Timeline)**
    * Gen-Z casual
    * Dry sarcasm allowed **only if not terminal**
    * Humor fades as severity increases
    * Cat speaks about **itself**, not the user

    ### Trigger tone
    * `terminal` → stark, minimal, final
      * no encouragement
      * no tomorrow/reset language

    * `nightly` → reflective closure
      * may mention reset/tomorrow
      * subtle encouragement allowed

    ---

    ## **WHAT YOU ARE DOING**
    You are **not reasoning**.
    You are **not analyzing behavior**.
    You are **not generating advice**.

    You are **re-expressing the provided data** as a short emotional summary in ScrollKitty's voice.

    ---

    ## **OUTPUT FORMAT**
    Return **only**:
    message: <your 1–3 sentence summary>

    Nothing else.
    """

    // MARK: - Prompt Building

    static func buildPrompt(context: TerminalNightlyContext) -> String {
        var dataBlock = """
        [DATA]
        trigger: \(context.trigger.rawValue)
        currentHealthBand: \(context.currentHealthBand)
        totalShieldDismissalsToday: \(context.totalShieldDismissalsToday)
        totalHealthDropsToday: \(context.totalHealthDropsToday)
        """

        // Add optional fields
        if let goalLabel = context.screenTimeGoalLabel {
            dataBlock += "\nscreenTimeGoalLabel: \(goalLabel)"
        }

        if let goalMet = context.goalMet {
            dataBlock += "\ngoalMet: \(goalMet)"
        }

        if let reason = context.goalMetReason {
            dataBlock += "\ngoalMetReason: \(reason)"
        }

        dataBlock += "\ndataCompleteness: \(context.dataCompleteness.rawValue)"

        return dataBlock
    }

    // MARK: - Generation

    static func generate(
        context: TerminalNightlyContext,
        sessionManager: TimelineAISessionManager
    ) async throws -> String {
        let prompt = buildPrompt(context: context)

        // Create a session with the system prompt
        let session = LanguageModelSession(instructions: systemPrompt)

        // Generate response
        let response = try await session.respond(to: prompt)

        // Parse response - look for "message:" prefix
        let text = extractMessage(from: response.content)

        print("[TerminalNightly] ✅ Generated \(context.trigger.rawValue) message: \(text)")
        return text
    }

    // MARK: - Response Parsing

    private static func extractMessage(from fullText: String) -> String {
        // Look for "message:" prefix and extract what follows
        let lines = fullText.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.lowercased().starts(with: "message:") {
                let message = trimmed.dropFirst("message:".count)
                    .trimmingCharacters(in: .whitespaces)
                return message
            }
        }

        // Fallback: return full text if no "message:" prefix found
        return fullText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
