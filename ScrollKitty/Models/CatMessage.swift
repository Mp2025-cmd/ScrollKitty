//
//  CatMessage.swift
//  ScrollKitty
//

import Foundation

struct CatMessage: Sendable {
    let message: String

    init(from responseText: String) {
        self.message = Self.cleanAndEnforce(from: responseText)
    }

    private static func cleanAndEnforce(from text: String) -> String {
        var s = text.trimmingCharacters(in: .whitespacesAndNewlines)

        s = s.replacingOccurrences(of: "\n+", with: " ", options: .regularExpression)
        s = s.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        s = s.trimmingCharacters(in: .whitespacesAndNewlines)

        if s.hasPrefix("\""), s.hasSuffix("\""), s.count > 2 {
            s = String(s.dropFirst().dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let labelStarters = ["dear diary", "diary:", "diary", "entry:", "message:", "response:"]
        for starter in labelStarters {
            if s.lowercased().hasPrefix(starter) {
                if let colon = s.firstIndex(of: ":") {
                    s = String(s[s.index(after: colon)...]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
                break
            }
        }

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

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
