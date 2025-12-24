//
//  NotificationDependency.swift
//  ScrollKitty
//
//  TCA dependency for observing system notifications
//

import Foundation
import ComposableArchitecture

private func timelineEventsFileURL() -> URL? {
    FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: "group.com.scrollkitty.app")?
        .appendingPathComponent("timelineEvents.json")
}

/// Dependency for observing NotificationCenter events in a TCA-compliant way
struct NotificationDependency {
    var bypassNotificationStream: @Sendable () -> AsyncStream<Void>
    var dailySummaryNotificationStream: @Sendable () -> AsyncStream<Void>
    var timelineEventsDidChangeStream: @Sendable () -> AsyncStream<Void>
}

extension NotificationDependency: DependencyKey {
    static let liveValue = Self(
        bypassNotificationStream: {
            AsyncStream { continuation in
                let tappedObserver = NotificationCenter.default.addObserver(
                    forName: .bypassNotificationTapped,
                    object: nil,
                    queue: .main
                ) { _ in
                    continuation.yield()
                }
                let receivedObserver = NotificationCenter.default.addObserver(
                    forName: .bypassNotificationReceived,
                    object: nil,
                    queue: .main
                ) { _ in
                    continuation.yield()
                }
                continuation.onTermination = { _ in
                    NotificationCenter.default.removeObserver(tappedObserver)
                    NotificationCenter.default.removeObserver(receivedObserver)
                }
            }
        },
        dailySummaryNotificationStream: {
            AsyncStream { continuation in
                let tappedObserver = NotificationCenter.default.addObserver(
                    forName: .dailySummaryNotificationTapped,
                    object: nil,
                    queue: .main
                ) { _ in
                    continuation.yield()
                }
                let receivedObserver = NotificationCenter.default.addObserver(
                    forName: .dailySummaryNotificationReceived,
                    object: nil,
                    queue: .main
                ) { _ in
                    continuation.yield()
                }
                continuation.onTermination = { _ in
                    NotificationCenter.default.removeObserver(tappedObserver)
                    NotificationCenter.default.removeObserver(receivedObserver)
                }
            }
        },
        timelineEventsDidChangeStream: {
            AsyncStream { continuation in
                guard let url = timelineEventsFileURL() else {
                    continuation.finish()
                    return
                }

                // Ensure the file exists so we can monitor it.
                if !FileManager.default.fileExists(atPath: url.path) {
                    try? Data("[]".utf8).write(to: url, options: [.atomic])
                }

                let fd = open(url.path, O_EVTONLY)
                guard fd >= 0 else {
                    continuation.finish()
                    return
                }

                let source = DispatchSource.makeFileSystemObjectSource(
                    fileDescriptor: fd,
                    eventMask: [.write, .rename, .delete],
                    queue: .main
                )

                source.setEventHandler {
                    continuation.yield()
                }

                source.setCancelHandler {
                    close(fd)
                }

                source.resume()
                continuation.onTermination = { _ in
                    source.cancel()
                }
            }
        }
    )

    static let testValue = Self(
        bypassNotificationStream: { AsyncStream { _ in } },
        dailySummaryNotificationStream: { AsyncStream { _ in } },
        timelineEventsDidChangeStream: { AsyncStream { _ in } }
    )
}

extension DependencyValues {
    var notifications: NotificationDependency {
        get { self[NotificationDependency.self] }
        set { self[NotificationDependency.self] = newValue }
    }
}
