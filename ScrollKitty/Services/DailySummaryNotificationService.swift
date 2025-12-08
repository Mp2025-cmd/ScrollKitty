//
//  DailySummaryNotificationService.swift
//  ScrollKitty
//
//  Schedules daily 11 PM notification to trigger daily summary
//

import Foundation
import UserNotifications
import os.log

private let logger = Logger(subsystem: "com.scrollkitty.app", category: "Notifications")

actor DailySummaryNotificationService {
    static let shared = DailySummaryNotificationService()

    // nonisolated so it can be accessed from sync contexts
    nonisolated let notificationIdentifier = "scrollkitty.daily.summary"

    private init() {}

    // MARK: - Public API

    /// Request notification permissions
    /// - Returns: Tuple of (granted, deniedByUser) - deniedByUser is true if user explicitly denied
    func requestPermission() async -> (granted: Bool, deniedByUser: Bool) {
        let center = UNUserNotificationCenter.current()

        // Check current status first
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .denied {
            logger.warning("Permission previously denied by user")
            return (granted: false, deniedByUser: true)
        }

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            logger.info("Permission granted: \(granted)")
            return (granted: granted, deniedByUser: !granted)
        } catch {
            logger.error("Permission error: \(error.localizedDescription)")
            return (granted: false, deniedByUser: false)
        }
    }

    /// Schedule the daily 11 PM notification (timezone-aware)
    func scheduleDailySummaryNotification() async {
        let center = UNUserNotificationCenter.current()

        // Remove any existing scheduled notification
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])

        // Check if we have permission
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else {
            logger.warning("Not authorized - skipping schedule")
            return
        }

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "ScrollKitty"
        content.body = "Time to see how I survived today..."
        content.sound = .default
        content.categoryIdentifier = "DAILY_SUMMARY"

        // Schedule for 11 PM daily in user's current timezone
        var dateComponents = DateComponents()
        dateComponents.hour = 23
        dateComponents.minute = 0
        dateComponents.timeZone = TimeZone.current // Explicit timezone awareness

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            logger.info("Daily 11 PM summary notification scheduled (timezone: \(TimeZone.current.identifier))")
        } catch {
            logger.error("Failed to schedule: \(error.localizedDescription)")
        }
    }

    /// Cancel the daily notification
    func cancelDailySummaryNotification() async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        logger.info("Daily summary notification cancelled")
    }

    /// Check if notification is already scheduled
    func isScheduled() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        return pending.contains { $0.identifier == notificationIdentifier }
    }

    /// Register notification categories (thread-safe, can be called from any context)
    nonisolated func registerCategories() {
        let center = UNUserNotificationCenter.current()

        // Category for daily summary (can add actions later if needed)
        let summaryCategory = UNNotificationCategory(
            identifier: "DAILY_SUMMARY",
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        center.setNotificationCategories([summaryCategory])
        logger.info("Notification categories registered")
    }
}
