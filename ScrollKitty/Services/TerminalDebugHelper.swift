//
//  TerminalDebugHelper.swift
//  ScrollKitty
//
//  Debug utilities for testing terminal/nightly AI messages quickly
//  WITHOUT spending 90 minutes draining health manually
//

import Foundation

#if DEBUG
enum TerminalDebugHelper {
    
    private static let appGroupID = "group.com.scrollkitty.app"
    
    /// Test Scenario: 6 hours used, exceeding 4-hour limit by 2 hours
    static func setupTerminalTest_SlightlyOver() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        
        let now = Date()
        
        // Set a 4-hour daily limit (240 minutes)
        defaults.set(240, forKey: "dailyLimit")
        
        // Simulate 6 hours of phone use (over 4 hour limit)
        defaults.set(21600.0, forKey: "cumulativePhoneUseSeconds") // 6 hours = 21600 seconds
        defaults.set(now.addingTimeInterval(-21600), forKey: "firstBypassTime") // Started 6h ago
        defaults.set(now, forKey: "lastBypassTime") // Just now
        
        print("[TerminalDebugHelper] ✅ Setup: 6 hours usage (exceeds 4-hour limit by 2 hours)")
        print("  - dailyLimit: 240 minutes (4 hours)")
        print("  - cumulativePhoneUseSeconds: 21600.0 (6 hours)")
        print("  - Expected: 'exceeding the 4-hour limit by 2 hours'")
    }
    
    /// Test Scenario: Way over limit (terminal state)
    static func setupTerminalTest_WayOver() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        
        let now = Date()
        
        // Simulate 6 hours of phone use (way over 2 hour limit)
        defaults.set(21600.0, forKey: "cumulativePhoneUseSeconds") // 6 hours = 21600 seconds
        defaults.set(now.addingTimeInterval(-21600), forKey: "firstBypassTime") // Started 6h ago
        defaults.set(now, forKey: "lastBypassTime") // Just now
        
        print("[TerminalDebugHelper] ✅ Setup: 6 hours usage (way over limit)")
        print("  - cumulativePhoneUseSeconds: 21600.0")
        print("  - firstBypassTime: \(now.addingTimeInterval(-21600))")
        print("  - lastBypassTime: \(now)")
    }
    
    /// Test Scenario: Nightly summary (simulate 11 PM conditions with moderate usage)
    static func setupNightlyTest_ModerateUsage() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }

        // Set a 3-hour daily limit (180 minutes)
        defaults.set(180, forKey: "dailyLimit")

        // Simulate 2.5 hours of phone use (under 3 hour limit)
        defaults.set(9000.0, forKey: "cumulativePhoneUseSeconds") // 2.5 hours = 9000 seconds
        defaults.set(Date().addingTimeInterval(-9000), forKey: "firstBypassTime")
        defaults.set(Date(), forKey: "lastBypassTime")

        // Set health to a moderate level (60) - not terminal
        defaults.set(60, forKey: "catHealth")

        print("[TerminalDebugHelper] ✅ Setup: 2.5 hours usage (under 3-hour limit, HP=60)")
        print("  - dailyLimit: 180 minutes (3 hours)")
        print("  - cumulativePhoneUseSeconds: 9000.0 (2.5 hours)")
        print("  - catHealth: 60")
        print("  - Expected: Nightly summary at 11 PM window")
    }

    /// Test Scenario: Nightly summary with heavy usage (over limit)
    static func setupNightlyTest_HeavyUsage() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }

        // Set a 2-hour daily limit (120 minutes)
        defaults.set(120, forKey: "dailyLimit")

        // Simulate 5 hours of phone use (way over 2 hour limit)
        defaults.set(18000.0, forKey: "cumulativePhoneUseSeconds") // 5 hours = 18000 seconds
        defaults.set(Date().addingTimeInterval(-18000), forKey: "firstBypassTime")
        defaults.set(Date(), forKey: "lastBypassTime")

        // Set health to low but not terminal (20)
        defaults.set(20, forKey: "catHealth")

        print("[TerminalDebugHelper] ✅ Setup: 5 hours usage (over 2-hour limit, HP=20)")
        print("  - dailyLimit: 120 minutes (2 hours)")
        print("  - cumulativePhoneUseSeconds: 18000.0 (5 hours)")
        print("  - catHealth: 20")
        print("  - Expected: Nightly summary at 11 PM window")
    }

    /// Test Scenario: Within limit (nightly state)
    static func setupNightlyTest_WithinLimit() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }

        let now = Date()

        // Simulate 30 minutes of phone use (under 1 hour limit)
        defaults.set(1800.0, forKey: "cumulativePhoneUseSeconds") // 30 min = 1800 seconds
        defaults.set(now.addingTimeInterval(-1800), forKey: "firstBypassTime") // Started 30min ago
        defaults.set(now, forKey: "lastBypassTime") // Just now

        print("[TerminalDebugHelper] ✅ Setup: 30 minutes usage (within limit)")
        print("  - cumulativePhoneUseSeconds: 1800.0")
        print("  - firstBypassTime: \(now.addingTimeInterval(-1800))")
        print("  - lastBypassTime: \(now)")
    }
    
    /// Clear all session data (reset for clean testing)
    static func clearSessionData() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        
        defaults.removeObject(forKey: "cumulativePhoneUseSeconds")
        defaults.removeObject(forKey: "firstBypassTime")
        defaults.removeObject(forKey: "lastBypassTime")
        defaults.removeObject(forKey: "sessionStartTime")
        
        print("[TerminalDebugHelper] 🧹 Cleared all session tracking data")
    }
    
    /// Clear all timeline events (for clean testing)
    static func clearTimelineEvents() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        
        defaults.removeObject(forKey: "timelineEvents")
        
        print("[TerminalDebugHelper] 🧹 Cleared all timeline events")
    }
    
    /// Clear today's closing message flag (allows re-testing same day)
    static func clearTodayClosingMessageFlag() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let todayKey = "closingMessageDate_\(calendar.component(.year, from: now))_\(calendar.component(.dayOfYear, from: now))"
        
        defaults.removeObject(forKey: todayKey)
        
        print("[TerminalDebugHelper] 🧹 Cleared today's closing message flag: \(todayKey)")
    }
    
    /// Set health directly (bypasses CatHealthManager)
    static func setHealth(_ health: Int) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        
        defaults.set(health, forKey: "catHealth")
        
        print("[TerminalDebugHelper] 💉 Set health to: \(health)")
    }
    
    /// Enable 11 PM window testing (overrides time check)
    static func enable11PMWindowOverride() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        
        defaults.set(true, forKey: "debug_force11PMWindow")
        
        print("[TerminalDebugHelper] 🌙 Enabled 11 PM window override (will trigger nightly summaries)")
    }
    
    /// Disable 11 PM window override (return to normal time check)
    static func disable11PMWindowOverride() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        
        defaults.removeObject(forKey: "debug_force11PMWindow")
        
        print("[TerminalDebugHelper] ☀️ Disabled 11 PM window override (normal time checks)")
    }
    
    /// Test Scenario: Nightly light usage (minimal phone use, high health - HP=90)
    static func setupNightlyTest_Light() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        
        // Get user's ACTUAL limit
        let limitMinutes = defaults.integer(forKey: "dailyLimit")
        let limitHours = limitMinutes > 0 ? Double(limitMinutes) / 60.0 : 2.0
        
        // Set usage to only 25% of limit (very light usage)
        let usageHours = limitHours * 0.25
        let usageSeconds = usageHours * 3600.0
        
        defaults.set(usageSeconds, forKey: "cumulativePhoneUseSeconds")
        defaults.set(Date().addingTimeInterval(-usageSeconds), forKey: "firstBypassTime")
        defaults.set(Date(), forKey: "lastBypassTime")
        
        // Set health to 90 (feeling great!)
        defaults.set(90, forKey: "catHealth")
        
        print("[TerminalDebugHelper] ✅ Nightly Light: \(String(format: "%.1f", usageHours))h used / \(String(format: "%.1f", limitHours))h limit (HP=90 - feeling great!)")
    }
    
    /// Test Scenario: Nightly moderate usage (uses YOUR actual limit, sets usage UNDER it)
    static func setupNightlyTest_Moderate() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        
        // Get user's ACTUAL limit (don't override it!)
        let limitMinutes = defaults.integer(forKey: "dailyLimit")
        let limitHours = limitMinutes > 0 ? Double(limitMinutes) / 60.0 : 2.0
        
        // Set usage to 75% of limit (under limit)
        let usageHours = limitHours * 0.75
        let usageSeconds = usageHours * 3600.0
        
        defaults.set(usageSeconds, forKey: "cumulativePhoneUseSeconds")
        defaults.set(Date().addingTimeInterval(-usageSeconds), forKey: "firstBypassTime")
        defaults.set(Date(), forKey: "lastBypassTime")
        
        // Set health to 60 (not terminal)
        defaults.set(60, forKey: "catHealth")
        
        print("[TerminalDebugHelper] ✅ Nightly Moderate: \(String(format: "%.1f", usageHours))h used / \(String(format: "%.1f", limitHours))h limit (HP=60)")
    }
    
    /// Test Scenario: Nightly heavy usage (uses YOUR actual limit, sets usage OVER it)
    static func setupNightlyTest_Heavy() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        
        // Get user's ACTUAL limit (don't override it!)
        let limitMinutes = defaults.integer(forKey: "dailyLimit")
        let limitHours = limitMinutes > 0 ? Double(limitMinutes) / 60.0 : 2.0
        
        // Set usage to 150% of limit (over by 50%)
        let usageHours = limitHours * 1.5
        let usageSeconds = usageHours * 3600.0
        
        defaults.set(usageSeconds, forKey: "cumulativePhoneUseSeconds")
        defaults.set(Date().addingTimeInterval(-usageSeconds), forKey: "firstBypassTime")
        defaults.set(Date(), forKey: "lastBypassTime")
        
        // Set health to 20 (drained but not dead)
        defaults.set(20, forKey: "catHealth")
        
        let overBy = usageHours - limitHours
        print("[TerminalDebugHelper] ✅ Nightly Heavy: \(String(format: "%.1f", usageHours))h used / \(String(format: "%.1f", limitHours))h limit (+\(String(format: "%.1f", overBy))h over) (HP=20)")
    }
    
    /// Show current session data (for debugging)
    static func printCurrentSessionData() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            print("[TerminalDebugHelper] ❌ App Group not available")
            return
        }
        
        let cumulative = defaults.double(forKey: "cumulativePhoneUseSeconds")
        let firstBypass = defaults.object(forKey: "firstBypassTime") as? Date
        let lastBypass = defaults.object(forKey: "lastBypassTime") as? Date
        let sessionStart = defaults.object(forKey: "sessionStartTime") as? Date
        let health = defaults.integer(forKey: "catHealth")
        let force11PM = defaults.bool(forKey: "debug_force11PMWindow")
        
        print("[TerminalDebugHelper] 📊 Current Session Data:")
        print("  - catHealth: \(health)")
        print("  - cumulativePhoneUseSeconds: \(cumulative) (\(cumulative/3600.0)h)")
        print("  - firstBypassTime: \(firstBypass?.description ?? "nil")")
        print("  - lastBypassTime: \(lastBypass?.description ?? "nil")")
        print("  - sessionStartTime: \(sessionStart?.description ?? "nil")")
        print("  - debug_force11PMWindow: \(force11PM)")
    }
}
#endif

