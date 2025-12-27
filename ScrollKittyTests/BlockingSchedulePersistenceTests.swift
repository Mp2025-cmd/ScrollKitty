//
//  BlockingSchedulePersistenceTests.swift
//  ScrollKittyTests
//
//  Tests-first spec for BlockingSchedule persistence during onboarding.
//

import Testing
import ComposableArchitecture
import Foundation
@testable import ScrollKitty

struct BlockingSchedulePersistenceTests {

    @MainActor
    @Test func blockingSchedule_RoundTripsThroughJSON() throws {
        let schedule = BlockingSchedule(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "Work Hours",
            emoji: "💼",
            startTime: Date(timeIntervalSince1970: 60 * 60 * 9),   // 9:00
            endTime: Date(timeIntervalSince1970: 60 * 60 * 17),    // 17:00
            selectedDays: [.monday, .tuesday, .wednesday, .thursday, .friday],
            isEnabled: true
        )

        let data = try JSONEncoder().encode(schedule)
        let decoded = try JSONDecoder().decode(BlockingSchedule.self, from: data)
        #expect(decoded == schedule)
    }

    @MainActor
    @Test func onboarding_PersistsBlockingSchedule_WhenDetailCompletes() async throws {
        // Spec: when the user finishes the schedule detail screen, we must persist the schedule
        // (App Group storage) so the Shield infrastructure can read it when the app isn't running.

        let defaults = UserDefaults.appGroup
        defaults.removeObject(forKey: "blockingSchedule")

        var initialState = OnboardingFeature.State()
        initialState.path.append(.blockingScheduleDetail(BlockingScheduleDetailFeature.State(preset: .work)))

        let schedule = BlockingSchedule(
            name: "Work Hours",
            emoji: "💼",
            startTime: Date(timeIntervalSince1970: 60 * 60 * 9),
            endTime: Date(timeIntervalSince1970: 60 * 60 * 17),
            selectedDays: [.monday, .tuesday, .wednesday, .thursday, .friday],
            isEnabled: true
        )

        let detailID = try #require(initialState.path.ids.last)

        actor CallRecorder {
            var startMonitoringCount: Int = 0
            func incrementStartMonitoring() { startMonitoringCount += 1 }
        }

        let recorder = CallRecorder()

        var screenTime = ScreenTimeManager.testValue
        screenTime.startMonitoring = {
            await recorder.incrementStartMonitoring()
        }

        var userSettings = UserSettingsManager.testValue
        userSettings.saveBlockingSchedule = { schedule in
            let defaults = UserDefaults.appGroup
            if let encoded = try? JSONEncoder().encode(schedule) {
                defaults.set(encoded, forKey: "blockingSchedule")
            }
        }

        let store = TestStore(initialState: initialState) {
            OnboardingFeature()
        } withDependencies: {
            $0.screenTimeManager = screenTime
            $0.userSettings = userSettings
        }

        await store.send(.path(.element(id: detailID, action: .blockingScheduleDetail(.delegate(.completeWithSchedule(schedule)))))) {
            $0.path.append(.characterIntro(CharacterIntroFeature.State()))
        }

        await store.finish()

        // This is the spec assertion. It FAILS until the feature is implemented.
        let saved = defaults.data(forKey: "blockingSchedule")
        #expect(saved != nil)

        // Spec: after schedule is saved, monitoring should be reconfigured (DeviceActivity schedule).
        let startMonitoringCount = await recorder.startMonitoringCount
        #expect(startMonitoringCount == 1)

        // Cleanup
        defaults.removeObject(forKey: "blockingSchedule")
    }
}
