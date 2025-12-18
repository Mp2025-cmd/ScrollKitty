//
//  Format.swift
//  ScrollKitty
//

import Foundation

enum Format {
    static func hours(_ v: Double?) -> String? {
        guard let v else { return nil }
        
        // Convert to hours and minutes
        let totalMinutes = Int(v * 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        // Format as natural language
        if hours == 0 && minutes == 0 {
            return "0 minutes"
        } else if hours == 0 {
            return minutes == 1 ? "1 minute" : "\(minutes) minutes"
        } else if minutes == 0 {
            return hours == 1 ? "1 hour" : "\(hours) hours"
        } else {
            let hourStr = hours == 1 ? "1 hour" : "\(hours) hours"
            let minuteStr = minutes == 1 ? "1 minute" : "\(minutes) minutes"
            return "\(hourStr) \(minuteStr)"
        }
    }
}
