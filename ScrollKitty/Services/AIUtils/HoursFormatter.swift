//
//  HoursFormatter.swift
//  ScrollKitty
//

import Foundation

enum HoursFormatter {
    static func naturalLanguage(_ hours: Double?) -> String {
        guard let h = hours, h > 0 else { return "some time" }
        
        let whole = Int(h)
        let fraction = h - Double(whole)

        if h < 0.25 {
            return "a few minutes"
        }
        if h < 0.75 {
            return "about half an hour"
        }
        if h < 1.15 {
            return "about an hour"
        }

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
