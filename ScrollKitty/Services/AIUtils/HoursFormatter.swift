//
//  HoursFormatter.swift
//  ScrollKitty
//
//  Converts decimal hours to natural language strings
//  Pre-computed so the AI model doesn't have to do conversions
//

import Foundation

enum HoursFormatter {
    
    /// Converts decimal hours to natural language (e.g., 3.8 → "almost 4 hours")
    static func naturalLanguage(_ hours: Double?) -> String {
        guard let h = hours, h > 0 else { return "some time" }
        
        let whole = Int(h)
        let fraction = h - Double(whole)
        
        // Handle edge cases
        if h < 0.25 {
            return "a few minutes"
        }
        if h < 0.75 {
            return "about half an hour"
        }
        if h < 1.15 {
            return "about an hour"
        }
        
        // Main conversion logic
        switch fraction {
        case 0..<0.15:
            return "\(whole) hours"
        case 0.15..<0.35:
            return "around \(whole) and a quarter hours"
        case 0.35..<0.65:
            return "around \(whole) and a half hours"
        case 0.65..<0.85:
            return "almost \(whole + 1) hours"
        default:
            return "almost \(whole + 1) hours"
        }
    }
    
    /// Converts decimal hours for "over by" context (e.g., 1.5 → "about an hour and a half")
    static func overByDescription(_ hours: Double?) -> String {
        guard let h = hours, h > 0.1 else { return "" }
        
        if h < 0.25 {
            return "a few minutes"
        }
        if h < 0.75 {
            return "about half an hour"
        }
        if h < 1.25 {
            return "about an hour"
        }
        
        let whole = Int(h)
        let fraction = h - Double(whole)
        
        if fraction < 0.35 {
            return "about \(whole) hours"
        } else if fraction < 0.65 {
            return "around \(whole) and a half hours"
        } else {
            return "almost \(whole + 1) hours"
        }
    }
}

