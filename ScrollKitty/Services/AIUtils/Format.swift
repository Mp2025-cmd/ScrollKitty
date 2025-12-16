//
//  Format.swift
//  ScrollKitty
//

import Foundation

enum Format {
    static func hours(_ v: Double?) -> String? {
        guard let v else { return nil }
        let s = String(format: "%.1f", v)
        return s.hasSuffix(".0") ? String(s.dropLast(2)) : s
    }
}
