//
//  OutputValidator.swift
//  ScrollKitty
//
//  Validates AI-generated output against strict rules
//

import Foundation

// MARK: - Validation Errors

enum ValidationError: Error, CustomStringConvertible {
    case notExactlyTwoSentences(found: Int)
    case containsAdvice(phrase: String)
    case contradictsLimitStatus
    case inventedTime(found: String)
    case mentionsBannedTerminalWords(word: String)

    var description: String {
        switch self {
        case .notExactlyTwoSentences(let found): 
            return "Output is not exactly 2 sentences (found \(found))."
        case .containsAdvice(let phrase): 
            return "Output contains advice/command phrase: '\(phrase)'."
        case .contradictsLimitStatus: 
            return "Output contradicts limitStatus."
        case .inventedTime(let found): 
            return "Output mentions a time not present in DATA: \(found)"
        case .mentionsBannedTerminalWords(let word): 
            return "Terminal output contains banned term: \(word)"
        }
    }
}

// MARK: - Output Validator

struct OutputValidator {

    /// Validates nightly summary output
    static func validateNightly(_ output: String, context: TerminalNightlyContext) throws {
        try validateSentenceCount(output)
        try validateNoAdvice(output)
        try validateNoContradiction(output, context: context)
        try validateTimes(output, context: context)
    }

    /// Validates terminal (HP=0) output with additional banned word checks
    static func validateTerminal(_ output: String, context: TerminalNightlyContext) throws {
        try validateSentenceCount(output)
        try validateNoAdvice(output)
        try validateNoContradiction(output, context: context)
        try validateTimes(output, context: context)
        try validateNoBannedTerminalWords(output)
    }

    // MARK: - Validation Rules

    private static func validateSentenceCount(_ output: String) throws {
        let count = SentenceUtils.split(output).count
        if count != 2 { 
            throw ValidationError.notExactlyTwoSentences(found: count) 
        }
    }

    private static func validateNoAdvice(_ output: String) throws {
        let badPhrases = ["you should", "you need to", "try to", "remember to", "take a break", "make sure to"]
        let lower = output.lowercased()
        for p in badPhrases where lower.contains(p) {
            throw ValidationError.containsAdvice(phrase: p)
        }
    }

    // Cached regex for word boundary matching
    private static let overLimitPattern: NSRegularExpression? = {
        // Matches "over" as standalone or in "over by", "went over", but not "overview", "over there"
        try? NSRegularExpression(
            pattern: #"\b(over\s+by|went\s+over|over\s+the|over\s+your|past\s+the|past\s+your|exceeded)\b"#, 
            options: .caseInsensitive
        )
    }()
    
    private static func validateNoContradiction(_ output: String, context: TerminalNightlyContext) throws {
        let lower = output.lowercased()
        let mentionsWithin = lower.contains("within") || lower.contains("stayed within") || lower.contains("under")
        
        // Use regex for "over" to avoid false positives on "overview", "over there", etc.
        let mentionsPast: Bool = {
            guard let regex = overLimitPattern else {
                return lower.contains("exceeded") || lower.contains("past your")
            }
            let range = NSRange(output.startIndex..<output.endIndex, in: output)
            return regex.firstMatch(in: output, options: [], range: range) != nil
        }()

        switch context.limitStatus {
        case .within:
            if mentionsPast { throw ValidationError.contradictsLimitStatus }
        case .past:
            if mentionsWithin { throw ValidationError.contradictsLimitStatus }
        case .unknown:
            if mentionsWithin && mentionsPast { throw ValidationError.contradictsLimitStatus }
        }
    }

    private static func validateTimes(_ output: String, context: TerminalNightlyContext) throws {
        let pattern = #"(\b\d{1,2}:\d{2}\s?(AM|PM)\b)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return }

        let range = NSRange(output.startIndex..<output.endIndex, in: output)
        let matches = regex.matches(in: output, options: [], range: range)
        guard !matches.isEmpty else { return }

        let allowed = Set([
            context.firstUseTime?.uppercased(),
            context.lastUseTime?.uppercased(),
            context.terminalAtLocalTime?.uppercased()
        ].compactMap { $0 })

        for m in matches {
            if let r = Range(m.range(at: 1), in: output) {
                let found = String(output[r]).uppercased()
                if !allowed.contains(found) {
                    throw ValidationError.inventedTime(found: found)
                }
            }
        }
    }

    private static func validateNoBannedTerminalWords(_ output: String) throws {
        let banned = ["health", "hp", "zero", "healthband"]
        let lower = output.lowercased()
        for w in banned where lower.contains(w) {
            throw ValidationError.mentionsBannedTerminalWords(word: w)
        }
    }
}


