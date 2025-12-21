//
//  NotificationDependency.swift
//  ScrollKitty
//
//  TCA dependency for observing system notifications
//

import Foundation
import ComposableArchitecture

/// Dependency for observing NotificationCenter events in a TCA-compliant way
struct NotificationDependency {
    var bypassNotificationStream: @Sendable () -> AsyncStream<Void>
    var dailySummaryNotificationStream: @Sendable () -> AsyncStream<Void>
}

extension NotificationDependency: DependencyKey {
    static let liveValue = Self(
        bypassNotificationStream: {
            AsyncStream { continuation in
                let observer = NotificationCenter.default.addObserver(
                    forName: .bypassNotificationTapped,
                    object: nil,
                    queue: .main
                ) { _ in
                    continuation.yield()
                }
                continuation.onTermination = { _ in
                    NotificationCenter.default.removeObserver(observer)
                }
            }
        },
        dailySummaryNotificationStream: {
            AsyncStream { continuation in
                let observer = NotificationCenter.default.addObserver(
                    forName: .dailySummaryNotificationTapped,
                    object: nil,
                    queue: .main
                ) { _ in
                    continuation.yield()
                }
                continuation.onTermination = { _ in
                    NotificationCenter.default.removeObserver(observer)
                }
            }
        }
    )

    static let testValue = Self(
        bypassNotificationStream: { AsyncStream { _ in } },
        dailySummaryNotificationStream: { AsyncStream { _ in } }
    )
}

extension DependencyValues {
    var notifications: NotificationDependency {
        get { self[NotificationDependency.self] }
        set { self[NotificationDependency.self] = newValue }
    }
}
