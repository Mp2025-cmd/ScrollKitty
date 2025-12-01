//
//  TimelineFeature.swift
//  ScrollKitty
//
//  TCA Feature for Timeline with AI-powered messages
//

import ComposableArchitecture
import Foundation

@Reducer
struct TimelineFeature {
    @ObservableState
    struct State: Equatable {
        var timelineEvents: [TimelineEvent] = []
        var isLoading = false
        var showAIUnavailableNotice = false
        var hasShownAINotice = false
    }
    
    enum Action: Equatable {
        case onAppear
        case loadTimeline
        case timelineLoaded([TimelineEvent])
        case checkForWelcomeMessage
        case welcomeMessageGenerated(TimelineEvent?)
        case checkForDailySummary
        case dailySummaryGenerated(TimelineEvent?)
        case checkAIAvailability
        case aiAvailabilityChecked(Bool)
        case dismissAINotice
        case prewarmAI
    }
    
    @Dependency(\.userSettings) var userSettings
    @Dependency(\.timelineManager) var timelineManager
    @Dependency(\.timelineAI) var timelineAI
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.prewarmAI)
                    await send(.checkAIAvailability)
                    await send(.loadTimeline)
                    await send(.checkForWelcomeMessage)
                    await send(.checkForDailySummary)
                }
                
            case .prewarmAI:
                return .run { _ in
                    await timelineAI.prewarm()
                }
                
            case .checkAIAvailability:
                return .run { send in
                    let shouldShow = await timelineManager.shouldShowAIUnavailableNotice()
                    await send(.aiAvailabilityChecked(shouldShow))
                }
                
            case .aiAvailabilityChecked(let shouldShow):
                state.showAIUnavailableNotice = shouldShow
                return .none
                
            case .dismissAINotice:
                state.showAIUnavailableNotice = false
                state.hasShownAINotice = true
                return .run { _ in
                    await timelineManager.markAIUnavailableNoticeShown()
                }
                
            case .loadTimeline:
                state.isLoading = true
                return .run { send in
                    let events = await userSettings.loadTimelineEvents()
                    // Sort by timestamp descending (newest first)
                    let sorted = events.sorted { $0.timestamp > $1.timestamp }
                    await send(.timelineLoaded(sorted))
                }
                
            case .timelineLoaded(let events):
                state.timelineEvents = events
                state.isLoading = false
                return .none
                
            case .checkForWelcomeMessage:
                return .run { send in
                    let welcomeEvent = await timelineManager.getWelcomeMessage()
                    await send(.welcomeMessageGenerated(welcomeEvent))
                }
                
            case .welcomeMessageGenerated(let event):
                if let event = event {
                    // Save and reload
                    return .run { send in
                        await userSettings.appendTimelineEvent(event)
                        await send(.loadTimeline)
                    }
                }
                return .none
                
            case .checkForDailySummary:
                return .run { send in
                    let summaryEvent = await timelineManager.checkForDailySummary()
                    await send(.dailySummaryGenerated(summaryEvent))
                }
                
            case .dailySummaryGenerated(let event):
                if let event = event {
                    // Save and reload
                    return .run { send in
                        await userSettings.appendTimelineEvent(event)
                        await send(.loadTimeline)
                    }
                }
                return .none
            }
        }
    }
}
