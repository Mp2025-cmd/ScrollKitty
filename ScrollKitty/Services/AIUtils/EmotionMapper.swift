//
//  EmotionMapper.swift
//  ScrollKitty
//

import Foundation

enum EmotionMapper {
    static func nightlyEmotion(for healthBand: Int) -> String {
        switch healthBand {
        case 95...100:
            return "great and energized"
        case 85..<95:
            return "pretty good and solid"
        case 70..<85:
            return "okay but a bit tired"
        case 50..<70:
            return "worn out and exhausted"
        case 25..<50:
            return "really drained and weak"
        default:
            return "completely wiped out"
        }
    }

    static func terminalEmotion(for healthBand: Int) -> String {
        return "completely drained and done"
    }
}
