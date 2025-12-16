//
//  Format.swift
//  ScrollKitty
//
//  Formatting utilities for hours and other values
//

import Foundation

enum Format {
    /// Formats hours as a clean string (removes .0 if present)
    static func hours(_ v: Double?) -> String? {
        guard let v else { return nil }
        let s = String(format: "%.1f", v)
        return s.hasSuffix(".0") ? String(s.dropLast(2)) : s
    }
}


