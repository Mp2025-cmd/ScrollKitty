//
//  StableHash.swift
//  ScrollKitty
//

import Foundation

enum StableHash {
    static func hash(_ s: String) -> Int {
        var h = 5381
        for u in s.unicodeScalars { h = ((h << 5) &+ h) &+ Int(u.value) }
        return h
    }
}
