//
//  SettingsAppSelectionTests.swift
//  ScrollKittyTests
//
//  Tests-first spec for Settings app selection (FamilyControls).
//

import Testing
import ComposableArchitecture
import FamilyControls
import Foundation
@testable import ScrollKitty

struct SettingsAppSelectionTests {

    @MainActor
    @Test func settings_OnAppear_LoadsSelectedAppsIntoState() async throws {
        let selection = try makeSelection(includeEntireCategory: true)

        var userSettings = UserSettingsManager.testValue
        userSettings.loadBlockingSchedule = { nil }
        userSettings.loadSelectedApps = { selection }

        var initialState = SettingsFeature.State()
        initialState.currentBlockingSchedule = BlockingSchedule(
            name: "Work",
            emoji: "💼",
            startTime: Date(timeIntervalSince1970: 60 * 60 * 9),
            endTime: Date(timeIntervalSince1970: 60 * 60 * 17),
            selectedDays: [.monday],
            isEnabled: true
        )

        let store = TestStore(initialState: initialState) {
            SettingsFeature()
        } withDependencies: {
            $0.userSettings = userSettings
        }

        await store.send(.onAppear)
        await store.receive(\.blockingScheduleLoaded, nil) {
            $0.currentBlockingSchedule = nil
        }
        await store.receive(\.selectedAppsLoaded, selection) {
            $0.selectedApps = selection
        }

        #expect(store.state.selectedApps.includeEntireCategory == true)
    }

    @MainActor
    @Test func settings_AppPickerDone_PersistsSelection_AndRefreshesShieldInfra() async throws {
        actor Recorder {
            var savedSelectionCount = 0
            var applyShieldsCount = 0
            var startMonitoringCount = 0
            func saved() { savedSelectionCount += 1 }
            func applied() { applyShieldsCount += 1 }
            func started() { startMonitoringCount += 1 }
        }

        let recorder = Recorder()

        var userSettings = UserSettingsManager.testValue
        userSettings.saveSelectedApps = { _ in await recorder.saved() }

        var screenTime = ScreenTimeManager.testValue
        screenTime.applyShields = { await recorder.applied() }
        screenTime.startMonitoring = { await recorder.started() }

        var initialState = SettingsFeature.State()
        initialState.isAppPickerPresented = true

        let store = TestStore(initialState: initialState) {
            SettingsFeature()
        } withDependencies: {
            $0.userSettings = userSettings
            $0.screenTimeManager = screenTime
        }

        await store.send(SettingsFeature.Action.binding(.set(\SettingsFeature.State.isAppPickerPresented, false))) {
            $0.isAppPickerPresented = false
        }
        await store.finish()
        #expect(store.state.isAppPickerPresented == false)

        #expect(await recorder.savedSelectionCount == 1)
        #expect(await recorder.applyShieldsCount == 1)
        #expect(await recorder.startMonitoringCount == 1)
    }

    @MainActor
    @Test func settings_AppSelection_DoesNotMutateCatHealth() async throws {
        let defaults = UserDefaults.appGroup
        let previous = defaults.object(forKey: "catHealth")
        defaults.set(55, forKey: "catHealth")

        var userSettings = UserSettingsManager.testValue
        userSettings.saveSelectedApps = { _ in }

        var initialState = SettingsFeature.State()
        initialState.isAppPickerPresented = true
        let store = TestStore(initialState: initialState) {
            SettingsFeature()
        } withDependencies: {
            $0.userSettings = userSettings
        }

        await store.send(SettingsFeature.Action.binding(.set(\SettingsFeature.State.isAppPickerPresented, false))) {
            $0.isAppPickerPresented = false
        }
        await store.finish()

        #expect(defaults.integer(forKey: "catHealth") == 55)

        if let previous {
            defaults.set(previous, forKey: "catHealth")
        } else {
            defaults.removeObject(forKey: "catHealth")
        }
    }
}

private func makeSelection(includeEntireCategory: Bool) throws -> FamilyActivitySelection {
    let json = """
    {
      "includeEntireCategory": \(includeEntireCategory ? "true" : "false"),
      "applicationTokens": [],
      "categoryTokens": [],
      "webDomainTokens": [],
      "untokenizedApplicationIdentifiers": [],
      "untokenizedCategoryIdentifiers": [],
      "untokenizedWebDomainIdentifiers": []
    }
    """
    let data = try #require(json.data(using: .utf8))
    return try JSONDecoder().decode(FamilyActivitySelection.self, from: data)
}
