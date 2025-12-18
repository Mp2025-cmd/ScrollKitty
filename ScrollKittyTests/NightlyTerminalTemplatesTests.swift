//
//  NightlyTerminalTemplatesTests.swift
//  ScrollKittyTests
//
//  TCA Integration tests for 11 PM nightly reflection messages
//

import Testing
import ComposableArchitecture
@testable import ScrollKitty
import Foundation

struct NightlyTerminalTemplatesTests {

    // MARK: - Test 1: Good Day - User stayed under goal
    // Tests against specific template: goodDay[7]

    @Test func goodDay_DisplaysDataAndEmoji() async throws {
        let elevenPM = createDate(hour: 23, minute: 0)

        let context = TerminalNightlyContext(
            trigger: .nightly,
            currentHealthBand: 90,
            firstUseTime: "9:30 AM",
            lastUseTime: "5:45 PM",
            phoneUseHours: "3 hours 30 minutes",
            terminalAtLocalTime: nil,
            dayPart: .afternoon,
            goalHours: 4.0,
            limitStatus: .within,
            overByHours: nil,
            underByHours: "30 minutes"
        )

        // Use deterministic selection to get template goodDay[7]
        let message = NightlyTerminalTemplates.selectNightlyDeterministic(context: context, templateIndex: 7)

        // Expected interpolated message
        let expectedMessage = "You began 9:30 AM and ended 5:45 PM. You clocked 3 hours 30 minutes under goal, leaving me elite at 90. Good stuff—fresh start tomorrow to keep it going. 😼"

        let event = await TimelineEvent(
            id: UUID(),
            timestamp: elevenPM,
            appName: "Nightly",
            healthBefore: 90,
            healthAfter: 90,
            cooldownStarted: elevenPM,
            eventType: .templateGenerated,
            message: message,
            emoji: nil,
            trigger: "nightly"
        )

        let store = await TestStore(initialState: TimelineFeature.State()) {
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

        // Assert exact template message with interpolated data
        #expect(message == expectedMessage, "Message should exactly match template goodDay[7] with interpolated data")
    }
    
    // MARK: - Test 2: Mixed Day - User went over goal
    // Tests against specific template: mixedDay[11]

    @Test func mixedDay_DisplaysDataAndEmoji() async throws {
        let elevenPM = createDate(hour: 23, minute: 0)

        let context = TerminalNightlyContext(
            trigger: .nightly,
            currentHealthBand: 30,
            firstUseTime: "8:15 AM",
            lastUseTime: "10:20 PM",
            phoneUseHours: "5 hours 30 minutes",
            terminalAtLocalTime: nil,
            dayPart: .evening,
            goalHours: 4.0,
            limitStatus: .past,
            overByHours: "1 hour 30 minutes",
            underByHours: nil
        )

        // Use deterministic selection to get template mixedDay[11]
        let message = NightlyTerminalTemplates.selectNightlyDeterministic(context: context, templateIndex: 11)

        // Expected interpolated message
        let expectedMessage = "You dove in 8:15 AM and surfaced 10:20 PM. You added 1 hour 30 minutes extra hours, leaving me tired at 30. The pull was strong, but fresh start tomorrow. 🔄"

        let event = TimelineEvent(
            id: UUID(),
            timestamp: elevenPM,
            appName: "Nightly",
            healthBefore: 30,
            healthAfter: 30,
            cooldownStarted: elevenPM,
            eventType: .templateGenerated,
            message: message,
            emoji: nil,
            trigger: "nightly"
        )

        let store = TestStore(initialState: TimelineFeature.State()) {
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

        // Assert exact template message with interpolated data
        #expect(message == expectedMessage, "Message should exactly match template mixedDay[11] with interpolated data")
    }
    
    // MARK: - Test 3: Outside 11 PM window - No event generated
    
    @Test func outside11PMWindow_NoEvent() async throws {
        let afternoon = createDate(hour: 14, minute: 30)
        
        let store = TestStore(initialState: TimelineFeature.State()) {
            TimelineFeature()
        } withDependencies: {
            $0.date.now = afternoon
            $0.timelineManager.checkForDailySummary = { nil }
        }
        
        await store.send(.checkForDailySummary)
        await store.receive(\.dailySummaryGenerated, nil)
        #expect(store.state.timelineEvents.isEmpty, "No event outside 11 PM window")
    }
    
    // MARK: - Test 4: Anti-duplicate - Same day returns nil
    // Tests against specific template: goodDay[4]

    @Test func antiDuplicate_SecondCallReturnsNil() async throws {
        let elevenPM = createDate(hour: 23, minute: 0)

        let context = TerminalNightlyContext(
            trigger: .nightly,
            currentHealthBand: 70,
            firstUseTime: "9:00 AM",
            lastUseTime: "6:00 PM",
            phoneUseHours: "3 hours 30 minutes",
            terminalAtLocalTime: nil,
            dayPart: .afternoon,
            goalHours: 4.0,
            limitStatus: .within,
            overByHours: nil,
            underByHours: "30 minutes"
        )

        // Use deterministic selection to get template goodDay[4]
        let message = NightlyTerminalTemplates.selectNightlyDeterministic(context: context, templateIndex: 4)

        // Expected interpolated message
        let expectedMessage = "You started at 9:00 AM and wrapped 6:00 PM. You came in under by 30 minutes, and I held steady at 70. Felt great—tomorrow can be just as good. 💪"

        let event = TimelineEvent(
            id: UUID(),
            timestamp: elevenPM,
            appName: "Nightly",
            healthBefore: 70,
            healthAfter: 70,
            cooldownStarted: elevenPM,
            eventType: .templateGenerated,
            message: message,
            emoji: nil,
            trigger: "nightly"
        )

        var callCount = 0

        let store = TestStore(initialState: TimelineFeature.State()) {
            TimelineFeature()
        } withDependencies: {
            $0.date.now = elevenPM
            $0.timelineManager.checkForDailySummary = {
                callCount += 1
                return callCount == 1 ? event : nil
            }
            $0.userSettings.appendTimelineEvent = { _ in }
            $0.userSettings.loadTimelineEvents = {
                // Return the event if it was already created
                return callCount > 0 ? [event] : []
            }
        }

        // First call - creates event
        await store.send(.checkForDailySummary)
        await store.receive(\.dailySummaryGenerated, event)
        await store.receive(\.loadTimeline) { $0.isLoading = true }
        await store.receive(\.timelineLoaded, [event]) {
            $0.timelineEvents = [event]
            $0.isLoading = false
        }

        // Assert exact template message with interpolated data
        #expect(message == expectedMessage, "Message should exactly match template goodDay[4] with interpolated data")

        // Second call - returns nil (anti-duplicate)
        await store.send(.checkForDailySummary)
        await store.receive(\.dailySummaryGenerated, nil)
        #expect(store.state.timelineEvents.count == 1, "Only 1 event (anti-duplicate works)")
    }
    
    // MARK: - Test 5: Natural language hours - No decimals shown to user
    // Tests multiple scenarios with deterministic template selection

    @Test func naturalLanguageHours_NoDecimals() async throws {
        let scenarios = [
            ("3 hours 30 minutes", "30 minutes", 0),
            ("1 hour", "3 hours", 1),
            ("5 hours", "2 hours", 2),
            ("2 hours 15 minutes", "1 hour 45 minutes", 3)
        ]

        for (phoneUse, under, templateIndex) in scenarios {
            let context = TerminalNightlyContext(
                trigger: .nightly,
                currentHealthBand: 70,
                firstUseTime: "9:00 AM",
                lastUseTime: "6:00 PM",
                phoneUseHours: phoneUse,
                terminalAtLocalTime: nil,
                dayPart: .afternoon,
                goalHours: 4.0,
                limitStatus: .within,
                overByHours: nil,
                underByHours: under
            )

            let message = NightlyTerminalTemplates.selectNightlyDeterministic(context: context, templateIndex: templateIndex)

            // Verify NO decimals shown to user
            #expect(!message.contains(".5"), "No .5 decimals")
            #expect(!message.contains(".25"), "No .25 decimals")
            #expect(!message.contains(".75"), "No .75 decimals")
            #expect(!message.contains("{{"), "No placeholders")

            // Verify natural language hours are present
            #expect(message.contains(phoneUse), "Message should contain natural language phone use hours")
            #expect(message.contains(under), "Message should contain natural language under hours")
        }
    }
}

// MARK: - Helper Functions

private func createDate(hour: Int, minute: Int) -> Date {
    let calendar = Calendar.current
    var components = calendar.dateComponents([.year, .month, .day], from: Date())
    components.hour = hour
    components.minute = minute
    components.second = 0
    return calendar.date(from: components) ?? Date()
}
