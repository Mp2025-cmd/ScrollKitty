//
//  UserDefaults+AppGroup.swift
//  ScrollKitty
//
//  Extension for App Group UserDefaults access
//

import Foundation

extension UserDefaults {
    /// Shared UserDefaults suite for App Group communication
    /// Used by main app and extensions (ShieldActionExtension, DeviceActivityMonitorExtension, etc.)
    static let appGroup: UserDefaults = {
        guard let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app") else {
            fatalError("Could not access App Group UserDefaults suite. Ensure App Group capability is enabled.")
        }
        return defaults
    }()
}
