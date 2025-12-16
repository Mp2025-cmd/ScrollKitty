//
//  CatMessage.swift
//  ScrollKitty
//
//  Output cleaning and enforcement for AI-generated messages
//

import Foundation

/// Cleans and enforces exactly 2 sentences from AI output
struct CatMessage: Sendable {
    let message: String

    init(from responseText: String) {
        self.message = Self.cleanAndEnforce(from: responseText)
    }

    private static func cleanAndEnforce(from text: String) -> String {
        var s = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Normalize whitespace
        s = s.replacingOccurrences(of: "\n+", with: " ", options: .regularExpression)
        s = s.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        s = s.trimmingCharacters(in: .whitespacesAndNewlines)

        // Strip surrounding quotes
        if s.hasPrefix("\""), s.hasSuffix("\""), s.count > 2 {
            s = String(s.dropFirst().dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // Strip common label prefixes (Dear diary, message:, etc.)
        let labelStarters = ["dear diary", "diary:", "diary", "entry:", "message:", "response:"]
        for starter in labelStarters {
            if s.lowercased().hasPrefix(starter) {
                if let colon = s.firstIndex(of: ":") {
                    s = String(s[s.index(after: colon)...]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
                break
            }
        }

        // EXACTLY 2 sentences (truncate extras, fix double periods)
        let sentences = SentenceUtils.split(s)
        if sentences.count >= 2 {
            let s1 = SentenceUtils.stripEndPunctuation(sentences[0])
            let s2 = SentenceUtils.stripEndPunctuation(sentences[1])
            return "\(s1). \(s2)."
        }
        if sentences.count == 1 {
            let s1 = SentenceUtils.stripEndPunctuation(sentences[0])
            return "\(s1)."
        }
        
        // Fallback: return cleaned text as-is
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


