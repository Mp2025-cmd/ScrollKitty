import Foundation
import ComposableArchitecture

// MARK: - DateProvider (TCA Dependency)

/// Provides current date/time for testing. Can be mocked to simulate different times.
struct DateProvider: Sendable {
    var now: @Sendable () -> Date
    var calendar: @Sendable () -> Calendar
}

// MARK: - Dependency Key

extension DateProvider: DependencyKey {
    static let liveValue = Self(
        now: { Date() },
        calendar: { Calendar.current }
    )
    
    /// Mock date provider for testing. Set a custom date to simulate time.
    static func mock(now: @escaping @Sendable () -> Date = { Date() }) -> Self {
        Self(
            now: now,
            calendar: { Calendar.current }
        )
    }
    
    /// Mock date provider with a fixed date
    static func fixed(_ date: Date) -> Self {
        Self(
            now: { date },
            calendar: { Calendar.current }
        )
    }
    
    static let testValue = Self(
        now: { Date() },
        calendar: { Calendar.current }
    )
    
    static let previewValue = testValue
}

// MARK: - Dependency Registration

extension DependencyValues {
    var dateProvider: DateProvider {
        get { self[DateProvider.self] }
        set { self[DateProvider.self] = newValue }
    }
}

