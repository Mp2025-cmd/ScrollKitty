//
//  DailySummaryTemplatesTests.swift
//  ScrollKittyTests
//
//  TCA integration tests for nightly/terminal summaries.
//

import Testing
import ComposableArchitecture
@testable import ScrollKitty
import Foundation

struct DailySummaryTemplatesTests {

    @MainActor
    @Test func nightlyWithinWithUnderBy_InterpolatesMinutes() async throws {
        let elevenPM = createDate(hour: 23, minute: 0)

        let context = DailySummaryContext(
            trigger: .nightly,
            catHealth: 85,
            healthBand: .healthy,
            dailyLimitMinutes: 60,
            bypassCountToday: 2,
            totalBypassMinutesToday: 30,
            firstBypassTimeToday: "9:30 AM",
            lastBypassTimeToday: "5:45 PM"
        )

        let message = DailySummaryTemplates.selectDeterministic(
            context: context,
            recentMessages: [],
            templateIndex: 0
        )

        let expectedMessage = "From 9:30 AM to 5:45 PM, you used 30 minutes across 2 passes, which is 30 minutes under your 1 hour goal. I feel steady tonight, let's keep that streak alive."

        let event = TimelineEvent(
            id: UUID(),
            timestamp: elevenPM,
            appName: "Nightly",
            healthBefore: 85,
            healthAfter: 85,
            cooldownStarted: elevenPM,
            eventType: .templateGenerated,
            message: message,
            emoji: nil,
            trigger: "nightly"
        )

        let store =  TestStore(initialState: TimelineFeature.State()) {
            TimelineFeature()
        } withDependencies: {
            $0.date.now = elevenPM
            $0.timelineManager.checkForDailySummary = { event }
            $0.userSettings.appendTimelineEvent = { _ in }
            $0.userSettings.loadTimelineEvents = { [event] }
        }

        await store.send(.checkForDailySummary)
        await store.receive(\.dailySummaryGenerated, event)
        await store.receive(\.loadTimeline) { $0.isLoading = true }
        await store.receive(\.timelineLoaded, [event]) {
            $0.timelineEvents = [event]
            $0.isLoading = false
        }

        #expect(message == expectedMessage)
        #expect(!message.contains("{{"))
    }

    @MainActor
    @Test func nightlyPast_InterpolatesOverBy() async throws {
        let elevenPM = createDate(hour: 23, minute: 0)

        let context = DailySummaryContext(
            trigger: .nightly,
            catHealth: 55,
            healthBand: .struggling,
            dailyLimitMinutes: 60,
            bypassCountToday: 3,
            totalBypassMinutesToday: 75,
            firstBypassTimeToday: "8:15 AM",
            lastBypassTimeToday: "10:20 PM"
        )

        let message = DailySummaryTemplates.selectDeterministic(
            context: context,
            recentMessages: [],
            templateIndex: 1
        )

        let expectedMessage = "Your total was 1 hour 15 minutes, 15 minutes past 1 hour. I feel stretched thin tonight, please give me a softer tomorrow."

        let event = TimelineEvent(
            id: UUID(),
            timestamp: elevenPM,
            appName: "Nightly",
            healthBefore: 55,
            healthAfter: 55,
            cooldownStarted: elevenPM,
            eventType: .templateGenerated,
            message: message,
            emoji: nil,
            trigger: "nightly"
        )

        let store =  TestStore(initialState: TimelineFeature.State()) {
            TimelineFeature()
        } withDependencies: {
            $0.date.now = elevenPM
            $0.timelineManager.checkForDailySummary = { event }
            $0.userSettings.appendTimelineEvent = { _ in }
            $0.userSettings.loadTimelineEvents = { [event] }
        }

        await store.send(.checkForDailySummary)
        await store.receive(\.dailySummaryGenerated, event)
        await store.receive(\.loadTimeline) { $0.isLoading = true }
        await store.receive(\.timelineLoaded, [event]) {
            $0.timelineEvents = [event]
            $0.isLoading = false
        }

        #expect(message == expectedMessage)
        #expect(!message.contains("{{"))
    }

    @MainActor
    @Test func terminalDead_InterpolatesOverBy() async throws {
        let onePM = createDate(hour: 13, minute: 46)

        let context = DailySummaryContext(
            trigger: .terminal,
            catHealth: 0,
            healthBand: .critical,
            dailyLimitMinutes: 60,
            bypassCountToday: 4,
            totalBypassMinutesToday: 90,
            firstBypassTimeToday: "12:24 AM",
            lastBypassTimeToday: "1:46 PM"
        )

        let message = DailySummaryTemplates.selectDeterministic(
            context: context,
            recentMessages: [],
            templateIndex: 2
        )

        let expectedMessage = "You went 30 minutes over your 1 hour goal, ending at 1 hour 30 minutes. I'm dead, I cannot follow you any further."

        let event = TimelineEvent(
            id: UUID(),
            timestamp: onePM,
            appName: "Terminal",
            healthBefore: 0,
            healthAfter: 0,
            cooldownStarted: onePM,
            eventType: .templateGenerated,
            message: message,
            emoji: nil,
            trigger: "terminal"
        )

        let store =  TestStore(initialState: TimelineFeature.State()) {
            TimelineFeature()
        } withDependencies: {
            $0.date.now = onePM
            $0.timelineManager.checkForDailySummary = { event }
            $0.userSettings.appendTimelineEvent = { _ in }
            $0.userSettings.loadTimelineEvents = { [event] }
        }

        await store.send(.checkForDailySummary)
        await store.receive(\.dailySummaryGenerated, event)
        await store.receive(\.loadTimeline) { $0.isLoading = true }
        await store.receive(\.timelineLoaded, [event]) {
            $0.timelineEvents = [event]
            $0.isLoading = false
        }

        #expect(message == expectedMessage)
        #expect(!message.contains("{{"))
    }

    @MainActor
    @Test func nonTerminal_NoEvent() async throws {
        let afternoon = createDate(hour: 14, minute: 30)

        let store =  TestStore(initialState: TimelineFeature.State()) {
            TimelineFeature()
        } withDependencies: {
            $0.date.now = afternoon
            $0.timelineManager.checkForDailySummary = { nil }
        }

        await store.send(.checkForDailySummary)
        await store.receive(\.dailySummaryGenerated, nil)
        #expect(store.state.timelineEvents.isEmpty)
    }

    @MainActor
    @Test func terminalOncePerDay_isSuppressed() async throws {
        let defaults = UserDefaults.appGroup

        let now = Date()
        let calendar = Calendar.current
        let todayKey = "closingMessageDate_\(calendar.component(.year, from: now))_\(calendar.component(.dayOfYear, from: now))"

        defaults.removeObject(forKey: todayKey)
        defaults.set(2, forKey: "bypassCountToday")
        defaults.set(30, forKey: "totalBypassMinutesToday")
        defaults.set(Date(timeIntervalSince1970: 0), forKey: "firstBypassTimeToday")
        defaults.set(Date(timeIntervalSince1970: 60), forKey: "lastBypassTimeToday")

        let catHealth = CatHealthManager(
            loadHealth: {
                CatHealthData(health: 0, catState: .dead, formattedTime: "0m")
            }
        )

        let userSettings = UserSettingsManager(
            saveSelectedApps: { _ in },
            loadSelectedApps: { nil },
            saveDailyLimit: { _ in },
            loadDailyLimit: { 60 },
            saveShieldInterval: { _ in },
            loadShieldInterval: { nil },
            saveFocusWindow: { _ in },
            loadFocusWindow: { nil },
            saveGlobalHealth: { _ in },
            loadGlobalHealth: { 100 },
            initializeHealth: { },
            saveCooldownEnd: { _ in },
            loadCooldownEnd: { nil },
            clearCooldown: { },
            appendTimelineEvent: { _ in },
            loadTimelineEvents: { [] },
            clearTimelineEvents: { },
            saveTimelineEvents: { _ in },
            saveOnboardingProfile: { _ in },
            loadOnboardingProfile: { nil },
            appendMessageHistory: { _ in },
            loadMessageHistory: { [] },
            loadRecentMessages: { _ in [] },
            getTodayTotal: { 0 }
        )

        let terminalEvent1 = await withDependencies {
            $0.catHealth = catHealth
            $0.userSettings = userSettings
        } operation: {
            await TimelineManager.liveValue.checkForDailySummary()
        }

        #expect(terminalEvent1 != nil)
        #expect(terminalEvent1?.trigger == TimelineEntryTrigger.terminal.rawValue)

        // Second call (same day): once-per-day key suppresses duplicate terminal.
        let terminalEvent2 = await withDependencies {
            $0.catHealth = catHealth
            $0.userSettings = userSettings
        } operation: {
            await TimelineManager.liveValue.checkForDailySummary()
        }

        #expect(terminalEvent2 == nil)

        // Cleanup
        defaults.removeObject(forKey: todayKey)
        defaults.removeObject(forKey: "bypassCountToday")
        defaults.removeObject(forKey: "totalBypassMinutesToday")
        defaults.removeObject(forKey: "firstBypassTimeToday")
        defaults.removeObject(forKey: "lastBypassTimeToday")
    }
}

private func createDate(hour: Int, minute: Int) -> Date {
    let calendar = Calendar.current
    var components = calendar.dateComponents([.year, .month, .day], from: Date())
    components.hour = hour
    components.minute = minute
    components.second = 0
    return calendar.date(from: components) ?? Date()
}
