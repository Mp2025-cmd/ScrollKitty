//
//  TimelineAISessionManager.swift
//  ScrollKitty
//
//  Actor managing AI session lifecycle with context preservation
//

import Foundation
import FoundationModels

actor TimelineAISessionManager {
    private var session: LanguageModelSession?
    private var sessionDate: Date?
    private let systemInstructions: String

    private let summarizationPrompt = """
    Summarize this cat's diary entries into a brief paragraph.
    Capture the emotional journey and key events.
    Keep it under 100 words.
    """

    init(systemInstructions: String) {
        self.systemInstructions = systemInstructions
    }

    // MARK: - Session Management

    func getSession() -> LanguageModelSession {
        let today = Calendar.current.startOfDay(for: Date())

        // Reset session daily (fresh context each day)
        if session == nil || sessionDate != today {
            session = LanguageModelSession(instructions: systemInstructions)
            sessionDate = today
            print("[TimelineAI] 🆕 Created new session for today")
        }

        return session!
    }

    func prewarm() async {
        let session = getSession()
        await session.prewarm()
        print("[TimelineAI] ✅ Session prewarmed and retained")
    }

    func resetSession() {
        session = nil
        sessionDate = nil
        print("[TimelineAI] 🔄 Session reset")
    }

    // MARK: - Context Management

    /// Check if context window is near capacity and summarize if needed
    /// Returns the summary if one was created, nil otherwise
    func summarizeIfNeeded() async throws -> String? {
        guard let session = session else { return nil }

        // Estimate context usage (rough: 4 chars ≈ 1 token)
        let transcriptText = estimateTranscriptText(session.transcript)
        let estimatedTokens = transcriptText.count / 4

        // Only summarize if we're at ~70% capacity (2800 of 4096 tokens)
        guard estimatedTokens > 2800 else { return nil }

        print("[TimelineAI] ⚠️ Context at \(estimatedTokens) tokens (~\(estimatedTokens * 100 / 4096)%) - summarizing...")

        // Create summarizer session
        let summarizer = LanguageModelSession(instructions: summarizationPrompt)
        let summaryResponse = try await summarizer.respond(to: transcriptText)
        let summary = summaryResponse.content

        // Reset main session with summary injected as context
        self.session = LanguageModelSession(instructions: systemInstructions)
        self.sessionDate = Calendar.current.startOfDay(for: Date())

        // Prime the new session with the summary context
        _ = try? await self.session?.respond(to: "Previous diary summary for context: \(summary)")

        print("[TimelineAI] ✅ Context summarized and session reset")
        return summary
    }

    // MARK: - Private Helpers

    private func estimateTranscriptText(_ transcript: Transcript) -> String {
        var result = ""
        for entry in transcript {
            switch entry {
            case .prompt(let prompt):
                result += extractText(from: prompt.segments)
            case .response(let response):
                result += extractText(from: response.segments)
            default:
                break
            }
        }
        return result
    }

    private func extractText(from segments: [Transcript.Segment]) -> String {
        segments.compactMap { segment -> String? in
            if case .text(let textSegment) = segment {
                return textSegment.content
            }
            return nil
        }.joined(separator: " ")
    }
}
