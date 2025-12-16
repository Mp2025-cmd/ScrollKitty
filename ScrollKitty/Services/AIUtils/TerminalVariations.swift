//
//  TerminalVariations.swift
//  ScrollKitty
//
//  Phrase variations for terminal messages (opener/closer)
//

import Foundation

enum TerminalVariations {

    static let openers: [String] = [
        "You used your phone for",
        "Today you used your phone for",
        "Your phone time hit",
        "Your total phone use was"
    ]

    static let closersNight: [String] = [
        "I'm completely wiped out, drained, and done for the night.",
        "I'm running on nothing, totally drained, and done for the night.",
        "I'm empty, exhausted, and done for the night.",
        "I couldn't keep up, and I'm done for the night."
    ]

    static let closersDay: [String] = [
        "I'm completely wiped out, drained, and done for now.",
        "I'm running on nothing, totally drained, and done for now.",
        "I'm empty, exhausted, and done for now.",
        "I couldn't keep up, and I'm done for now."
    ]

    /// Picks an element from array using stable seed
    static func pick<T>(_ arr: [T], seed: Int) -> T {
        arr[abs(seed) % arr.count]
    }
}


