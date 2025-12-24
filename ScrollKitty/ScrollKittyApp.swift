//
//  ScrollKittyApp.swift
//  ScrollKitty
//
//  Created by Peter on 10/19/25.
//

import SwiftUI
import ComposableArchitecture
import UserNotifications
import os.log

private let logger = Logger(subsystem: "com.scrollkitty.app", category: "App")

@main
struct ScrollKittyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let store = Store(
        initialState: AppFeature.State(),
        reducer: { AppFeature() }
    )

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
                .onAppear {
                    // Schedule daily 11 PM notification
                    Task {
                        let service = DailySummaryNotificationService.shared
                        service.registerCategories()
                        let result = await service.requestPermission()

                        if result.granted {
                            await service.scheduleDailySummaryNotification()
                        } else if result.deniedByUser {
                            // Post notification so UI can show feedback if needed
                            NotificationCenter.default.post(
                                name: .notificationPermissionDenied,
                                object: nil
                            )
                            logger.warning("User denied notification permission - daily summary notifications disabled")
                        }
                    }
                }
        }
    }
}

// MARK: - App Delegate for Notification Handling

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let identifier = notification.request.content.categoryIdentifier
        if identifier == "DAILY_SUMMARY" {
            NotificationCenter.default.post(name: .dailySummaryNotificationReceived, object: nil)
            logger.info("Daily summary notification received in foreground")
        } else if identifier == "BYPASS" {
            NotificationCenter.default.post(name: .bypassNotificationReceived, object: nil)
            logger.info("Bypass notification received in foreground")
        }

        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.content.categoryIdentifier

        if identifier == "DAILY_SUMMARY" {
            // Post notification to trigger daily summary
            NotificationCenter.default.post(name: .dailySummaryNotificationTapped, object: nil)
            logger.info("Daily summary notification tapped")
        } else if identifier == "BYPASS" {
            // Post notification to show cat state sheet
            NotificationCenter.default.post(name: .bypassNotificationTapped, object: nil)
            logger.info("Bypass notification tapped")
        }

        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let dailySummaryNotificationTapped = Notification.Name("dailySummaryNotificationTapped")
    static let bypassNotificationTapped = Notification.Name("bypassNotificationTapped")
    static let dailySummaryNotificationReceived = Notification.Name("dailySummaryNotificationReceived")
    static let bypassNotificationReceived = Notification.Name("bypassNotificationReceived")
    static let notificationPermissionDenied = Notification.Name("notificationPermissionDenied")
    static let timelineEventsDidChange = Notification.Name("timelineEventsDidChange")
}
