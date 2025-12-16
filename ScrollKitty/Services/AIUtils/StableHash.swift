//
//  StableHash.swift
//  ScrollKitty
//
//  Deterministic hash for variation seed generation
//

import Foundation

enum StableHash {
    /// Computes a deterministic hash from a string for variation seed
    static func hash(_ s: String) -> Int {
        var h = 5381
        for u in s.unicodeScalars { h = ((h << 5) &+ h) &+ Int(u.value) }
        return h
    }
}


