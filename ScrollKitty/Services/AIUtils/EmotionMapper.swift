//
//  EmotionMapper.swift
//  ScrollKitty
//
//  Maps health bands to pre-defined emotion descriptions
//  Pre-computed so the AI model doesn't have to interpret health values
//

import Foundation

enum EmotionMapper {
    
    /// Maps health band to a cat emotion description for nightly summaries
    static func nightlyEmotion(for healthBand: Int) -> String {
        switch healthBand {
        case 80...100:
            return "relieved and content"
        case 60..<80:
            return "okay but a little tired"
        case 40..<60:
            return "worn out and exhausted"
        case 20..<40:
            return "really drained, barely holding on"
        default:
            return "completely wiped and empty"
        }
    }
    
    /// Maps health band to a terminal emotion description (stark, minimal)
    static func terminalEmotion(for healthBand: Int) -> String {
        // Terminal is always at HP=0, but we still map for consistency
        return "completely drained and done"
    }
}

