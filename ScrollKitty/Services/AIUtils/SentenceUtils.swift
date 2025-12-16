//
//  SentenceUtils.swift
//  ScrollKitty
//

import Foundation

enum SentenceUtils {
    private static let sentencePattern: NSRegularExpression? = {
        try? NSRegularExpression(pattern: #"(?<=[.!?])\s+(?=[A-Za-z"])"#)
    }()

    static func split(_ text: String) -> [String] {
        guard let regex = sentencePattern else {
            return text.split(whereSeparator: { $0 == "." || $0 == "!" || $0 == "?" })
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        
        let ns = text as NSString
        let full = NSRange(location: 0, length: ns.length)

        var out: [String] = []
        var lastIndex = 0

        for match in regex.matches(in: text, options: [], range: full) {
            let r = match.range
            let pieceRange = NSRange(location: lastIndex, length: r.location - lastIndex)
            let piece = ns.substring(with: pieceRange).trimmingCharacters(in: .whitespacesAndNewlines)
            if !piece.isEmpty { out.append(piece) }
            lastIndex = r.location + r.length
        }

        let tailRange = NSRange(location: lastIndex, length: ns.length - lastIndex)
        let tail = ns.substring(with: tailRange).trimmingCharacters(in: .whitespacesAndNewlines)
        if !tail.isEmpty { out.append(tail) }

        return out
    }

    static func stripEndPunctuation(_ s: String) -> String {
        var result = s
        while result.hasSuffix(".") || result.hasSuffix("!") || result.hasSuffix("?") {
            result = String(result.dropLast())
        }
        return result.trimmingCharacters(in: .whitespaces)
    }
}
