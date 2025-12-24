import SwiftUI
import AVFAudio
import ComposableArchitecture

// MARK: - TimelineFeature
@Reducer
struct TimelineFeature {

    @ObservableState
    struct State: Equatable {
        var timelineEvents: [TimelineEvent] = []
        var isLoading = false
        var selectedDay: Date? = nil
        var currentWeekStart: Date? = nil
        var moodNow: CatState? = nil
    }
    @Dependency(\.userSettings) var userSettings
    @Dependency(\.timelineManager) var timelineManager
    @Dependency(\.catHealth) var catHealth
    @Dependency(\.notifications) var notifications
    @Dependency(\.date) var date
    @Dependency(\.calendar) var calendar
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case onDisappear
        case loadTimeline
        case timelineLoaded([TimelineEvent])
        case loadMoodNow
        case moodNowLoaded(CatHealthData)
        case processRawEvents
        case rawEventsProcessed([TimelineEvent])
        case checkForWelcomeMessage
        case welcomeMessageGenerated(TimelineEvent?)
        case checkForDailyWelcome
        case dailyWelcomeGenerated(TimelineEvent?)
        case checkForDailySummary
        case dailySummaryGenerated(TimelineEvent?)
        case dayTapped(Date)
        case weekMoved(WeekNavigationDirection)
    }

    enum WeekNavigationDirection: Equatable {
        case previous
        case next
    }
    

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            enum CancelID { case timelineEvents }
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                let today = date.now
                let todayStart = calendar.startOfDay(for: today)
                state.selectedDay = todayStart
                state.currentWeekStart = calendar.startOfWeek(for: todayStart)

                return .merge(
                    .send(.loadTimeline),
                    .send(.checkForDailySummary),
                    .send(.loadMoodNow),
                    .run { send in
                        for await _ in notifications.timelineEventsDidChangeStream() {
                            await send(.loadTimeline)
                        }
                    }
                    .cancellable(id: CancelID.timelineEvents, cancelInFlight: true)
                )

            case .onDisappear:
                return .cancel(id: CancelID.timelineEvents)
                
            case .processRawEvents:
                return state.processRawEvents()
                
            case .rawEventsProcessed(let updatedEvents):
                // Save all updated events back to UserDefaults atomically, then reload
                return .run { [userSettings] send in
                    await userSettings.saveTimelineEvents(updatedEvents)
                    // Reload timeline to show template messages
                    await send(.loadTimeline)
                }
                
            case .loadTimeline:
                state.isLoading = true
                return .run { send in
                    let events = await userSettings.loadTimelineEvents()
                    await send(.timelineLoaded(events))
                }
                
            case .timelineLoaded(let events):
                state.timelineEvents = events
                state.isLoading = false
                return .none

            case .loadMoodNow:
                return .run { send in
                    let healthData = await catHealth.loadHealth()
                    await send(.moodNowLoaded(healthData))
                }

            case .moodNowLoaded(let data):
                state.moodNow = data.catState
                return .none
                
            case .checkForWelcomeMessage:
                return .run { send in
                    let welcomeEvent = await timelineManager.getWelcomeMessage()
                    await send(.welcomeMessageGenerated(welcomeEvent))
                }
                
            case .welcomeMessageGenerated(let event):
                if let event = event {
                    return .run { send in
                        await userSettings.appendTimelineEvent(event)
                        await send(.loadTimeline)
                        await send(.checkForDailyWelcome)
                    }
                }
                return .send(.checkForDailyWelcome)

            case .checkForDailyWelcome:
                return .run { send in
                    let dailyWelcomeEvent = await timelineManager.getDailyWelcome()
                    await send(.dailyWelcomeGenerated(dailyWelcomeEvent))
                }

            case .dailyWelcomeGenerated(let event):
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

            case .dayTapped(let date):
                let normalized = calendar.startOfDay(for: date)
                if let current = state.selectedDay, calendar.isDate(current, inSameDayAs: normalized) {
                    state.selectedDay = nil
                } else {
                    state.selectedDay = normalized
                }
                return .none

            case .weekMoved(let direction):
                guard let currentWeekStart = state.currentWeekStart else {
                    return .none
                }
                let delta = direction == .next ? 7 : -7
                guard let shiftedStart = calendar.date(byAdding: .day, value: delta, to: currentWeekStart) else {
                    return .none
                }
                let newWeekStart = calendar.startOfWeek(for: shiftedStart)
                let previousWeekStart = calendar.startOfWeek(for: currentWeekStart)
                state.currentWeekStart = newWeekStart

                if let selectedDay = state.selectedDay {
                    let normalizedSelected = calendar.startOfDay(for: selectedDay)
                    let offset = calendar.dateComponents([.day], from: previousWeekStart, to: normalizedSelected).day ?? 0
                    let clampedOffset = max(0, min(6, offset))
                    if let updatedSelection = calendar.date(byAdding: .day, value: clampedOffset, to: newWeekStart) {
                        state.selectedDay = updatedSelection
                    }
                }
                return .none
            }
        }
    }
}

// MARK: - TimelineView

struct TimelineView: View {
    @Bindable var store: StoreOf<TimelineFeature>
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Timeline Content
                if store.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(DesignSystem.Colors.primaryText)
                    Spacer()
                } else if store.timelineEvents.isEmpty {
                    Spacer()
                    EmptyTimelineView()
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        let sections = store.state.filteredEventsByDay(
                            from: store.timelineEvents,
                            selectedDay: store.selectedDay,
                            currentWeekStart: store.currentWeekStart,
                            using: calendar
                        )
                        VStack(spacing: 16) {
                            WeeklyCatReportView(
                                title: "ScrollKitty Report",
                                subtitle: store.state.formattedWeekRange(using: calendar),
                                days: store.state.weekDayPresentations(
                                    from: store.timelineEvents,
                                    selectedDay: store.selectedDay,
                                    using: calendar
                                ),
                                canMoveBackward: store.state.canMoveToPreviousWeek(
                                    events: store.timelineEvents,
                                    calendar: calendar
                                ),
                                canMoveForward: store.state.canMoveToNextWeek(
                                    today: Date(),
                                    calendar: calendar
                                ),
                                onSelectDay: { store.send(.dayTapped($0)) },
                                onPreviousWeek: { store.send(.weekMoved(.previous)) },
                                onNextWeek: { store.send(.weekMoved(.next)) }
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom)
                            if sections.isEmpty {
                                EmptyDayView()
                                    .padding(.horizontal, 34)
                            } else {
                                ZStack(alignment: .topLeading) {
                                    Rectangle()
                                        .fill(DesignSystem.Colors.timelineLine)
                                        .frame(width: 3)
                                        .padding(.leading, 38.5)
                                        .padding(.top, 52)
                                    VStack(spacing: 8) {
                                        ForEach(sections, id: \.date) { group in
                                            TimelineDayHeader(date: group.date)
                                                .padding(.leading, 32)
                                                .padding(.bottom, 16)

                                            ForEach(group.events, id: \.id) { event in
                                                TimelineItemView(event: event)
                                                    
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 120) // Space for tab bar
                    }
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
    }
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var todayStart: Date {
        calendar.startOfDay(for: Date())
    }
    
}

// MARK: - Timeline Day Header
struct TimelineDayHeader: View {
    let date: Date

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var body: some View {
        HStack(spacing: 0) {
            if isToday {
                Text("Today")
                    .font(.custom("Sofia Pro-Semi_Bold", size: 16))
                    .foregroundColor(DesignSystem.Colors.primaryText)
            } else {
                Text("\(TimelineFeature.State.formattedDate(for: date)) • \(TimelineFeature.State.formattedDayOfWeek(for: date))")
                    .font(.custom("Sofia Pro-Regular", size: 14))
                    .foregroundColor(DesignSystem.Colors.timelineSecondaryText)
            }
            Spacer()
        }
    }
}

// MARK: - Empty Day View
struct EmptyDayView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("No entries for this day yet")
                .font(.custom("Sofia Pro-Semi_Bold", size: 17))
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            Text("Pick another day or come back later to see more Scroll Kitty moments.")
                .font(.custom("Sofia Pro-Regular", size: 13))
                .foregroundColor(DesignSystem.Colors.timelineSecondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 36)
    }
}

// MARK: - Empty Timeline View
struct EmptyTimelineView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock")
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.timelineSecondaryText)
            
            Text("No timeline entries yet")
                .font(.custom("Sofia Pro-Semi_Bold", size: 18))
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            Text("Your journey with Scroll Kitty\nwill appear here")
                .font(.custom("Sofia Pro-Regular", size: 14))
                .foregroundColor(DesignSystem.Colors.timelineSecondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// MARK: - Timeline Item View
struct TimelineItemView: View {
    let event: TimelineEvent
    
    var body: some View {
        HStack(spacing: 0) {
            // Timeline icon (cat dashboard icon)
            Image("TabBar_Dashboard")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundColor(catState.iconColor)
                .frame(width: 27, height: 27)
                .background(DesignSystem.Colors.white)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(DesignSystem.Colors.timelineLine, lineWidth: 2)
                )
                .padding(.trailing, 6)
            
            // Card
            ZStack(alignment: .topLeading) {
                catState.backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 21))
                
                HStack(spacing: 0) {
                    // Left side - Text content
                    VStack(alignment: .leading, spacing: 13) {
                        HStack(spacing: 10) {
                            Text(formattedTime)
                                .font(DesignSystem.Typography.timelineTime())
                                .foregroundColor(catState.timeColor)
                            Text("Mood then")
                                .font(.custom("Sofia Pro-Regular", size: 12))
                                .foregroundColor(catState.timeColor.opacity(0.85))
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(messageText)
                            .font(DesignSystem.Typography.timelineMessage())
                            .foregroundColor(DesignSystem.Colors.white)
                            .tracking(DesignSystem.Typography.timelineMessageTracking)
                            .lineSpacing(DesignSystem.Typography.timelineMessageLineSpacing)
                            .fixedSize(horizontal: false, vertical: true) // Allow text to expand vertically
                        }
                    }
                    .padding(.leading, 13)
                    .padding(.top, 11)
                    .padding(.bottom, 13)
                    
                    Spacer()
                    
                    // Right side - Cat image
                    catState.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 133, height: 120)
                        .offset(y: 5)
                }
            }
            .frame(width: 310, height: 145)
            
            Spacer()
        }
        .padding(.leading, 27)
        .padding(.bottom, 15)
    }
    
    private var catState: CatState {
        CatState.from(health: event.healthAfter)
}

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: event.timestamp)
    }
    
    private var messageText: String {
        guard let message = event.message else { return "" }
        if let emoji = event.emoji {
            return "\(message) \(emoji)"
        }
        return message
    }
}



#if DEBUG
private func makePreviewTimelineEvents(now: Date, calendar: Calendar) -> [TimelineEvent] {
    func at(dayOffset: Int, hour: Int, minute: Int) -> Date {
        let dayStart = calendar.startOfDay(for: calendar.date(byAdding: .day, value: dayOffset, to: now) ?? now)
        return calendar.date(byAdding: .minute, value: hour * 60 + minute, to: dayStart) ?? dayStart
    }

    return [
        TimelineEvent(
            timestamp: at(dayOffset: 0, hour: 0, minute: 15),
            appName: "Daily Welcome",
            healthBefore: 100,
            healthAfter: 100,
            cooldownStarted: at(dayOffset: 0, hour: 0, minute: 15),
            eventType: .templateGenerated,
            message: TimelineTemplateMessages.dailyWelcome[14],
            trigger: TimelineEntryTrigger.dailyWelcome.rawValue
        ),
        TimelineEvent(
            timestamp: at(dayOffset: 0, hour: 7, minute: 3),
            appName: "Health Drop",
            healthBefore: 100,
            healthAfter: 80,
            cooldownStarted: at(dayOffset: 0, hour: 7, minute: 3),
            eventType: .templateGenerated,
            message: TimelineTemplateMessages.messages80HP[2],
            trigger: TimelineEntryTrigger.healthBandDrop.rawValue
        ),
        TimelineEvent(
            timestamp: at(dayOffset: 0, hour: 8, minute: 41),
            appName: "Health Drop",
            healthBefore: 80,
            healthAfter: 60,
            cooldownStarted: at(dayOffset: 0, hour: 8, minute: 41),
            eventType: .templateGenerated,
            message: TimelineTemplateMessages.messages60HP[19],
            trigger: TimelineEntryTrigger.healthBandDrop.rawValue
        ),
        TimelineEvent(
            timestamp: at(dayOffset: -1, hour: 22, minute: 57),
            appName: "Nightly",
            healthBefore: 60,
            healthAfter: 60,
            cooldownStarted: at(dayOffset: -1, hour: 22, minute: 57),
            eventType: .templateGenerated,
            message: "A quieter end to the day. I’m still here, still watching, still trying with you.",
            trigger: TimelineEntryTrigger.nightly.rawValue
        ),
        TimelineEvent(
            timestamp: at(dayOffset: -2, hour: 12, minute: 5),
            appName: "Health Drop",
            healthBefore: 60,
            healthAfter: 40,
            cooldownStarted: at(dayOffset: -2, hour: 12, minute: 5),
            eventType: .templateGenerated,
            message: TimelineTemplateMessages.messages40HP[0],
            trigger: TimelineEntryTrigger.healthBandDrop.rawValue
        )
    ]
}

#Preview("TimelineView - Mock Timeline") {
    let calendar = Calendar.current
    let now = Date()
    let events = makePreviewTimelineEvents(now: now, calendar: calendar)

    let store = Store(initialState: TimelineFeature.State()) {
        TimelineFeature()
    } withDependencies: {
        var userSettings = UserSettingsManager.testValue
        userSettings.loadTimelineEvents = { events }
        $0.userSettings = userSettings
        $0.timelineManager = TimelineManager.testValue
        $0.date.now = now
        $0.calendar = calendar
    }

    return TimelineView(store: store)
}
#endif
