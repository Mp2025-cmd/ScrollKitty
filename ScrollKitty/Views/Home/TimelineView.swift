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
        var selectedDate: Date = Date()
        var currentMonth: Date = Date()
        var showingCalendar = false
    }
    @Dependency(\.userSettings) var userSettings
    @Dependency(\.timelineManager) var timelineManager
    @Dependency(\.catHealth) var catHealth
    @Dependency(\.date) var date
    @Dependency(\.calendar) var calendar
    
    enum Action: Equatable {
        case onAppear
        case loadTimeline
        case timelineLoaded([TimelineEvent])
        case processRawEvents
        case rawEventsProcessed([TimelineEvent])
        case checkForWelcomeMessage
        case welcomeMessageGenerated(TimelineEvent?)
        case checkForDailyWelcome
        case dailyWelcomeGenerated(TimelineEvent?)
        case checkForDailySummary
        case dailySummaryGenerated(TimelineEvent?)
        case dateSelected(Date)
        case toggleCalendar
        case monthChanged(Date)
    }
    

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.loadTimeline)
                    await send(.checkForDailySummary)
                }
                
            case .dateSelected(let date):
                state.selectedDate = date
                state.showingCalendar = false
                return .none
                
            case .toggleCalendar:
                state.showingCalendar.toggle()
                return .none
                
            case .monthChanged(let month):
                state.currentMonth = month
                return .none
                
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
                // Header
                HStack {
                    Text("Timeline")
                        .font(.custom("Sofia Pro-Semi_Bold", size: 24))
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                .padding(.horizontal, 34)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
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
                    ZStack(alignment: .topLeading) {
                        // Vertical timeline line
                        Rectangle()
                            .fill(DesignSystem.Colors.timelineLine)
                            .frame(width: 3)
                            .padding(.leading, 39)
                            .padding(.top, 28)
                        
                            // Timeline items grouped by date
                        VStack(spacing: 0) {
                                ForEach(groupedEvents(), id: \.date) { group in
                                    DateHeaderView(
                                        date: group.date,
                                        isExpanded: store.showingCalendar,
                                        onToggle: { store.send(.toggleCalendar) }
                                    )
                                    .padding(.leading, 35)
                                    .padding(.bottom, 20)
                                    
                                    ForEach(group.events, id: \.id) { event in
                                        TimelineItemView(event: event)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 100) // Space for tab bar
                    }
                }
            }
        }
        .overlay(alignment: .top) {
            if store.showingCalendar {
                ZStack(alignment: .top) {
                    // Semi-transparent background
                    Color(red: 0, green: 0, blue: 0, opacity: 0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                store.send(.toggleCalendar)
                            }
                        }

                    // Calendar component
                    MonthCalendarView(
                        selectedDate: $store.selectedDate,
                        currentMonth: $store.currentMonth,
                        dateHealthStates: generateHealthStatesFromEvents(),
                        onDateSelected: { date in
                            store.send(.dateSelected(date))
                        },
                        onMonthChanged: { month in
                            store.send(.monthChanged(month))
                        }
                    )
                    .padding(.top, 120)
                    .padding(.horizontal, 16)
                }
                .transition(.scale(scale: 0.95, anchor: .top).combined(with: .opacity))
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    private func generateHealthStatesFromEvents() -> [Date: Int] {
        let calendar = Calendar.current
        var healthStates: [Date: Int] = [:]
        
        // Group events by date and get the final health for each day
        let grouped = Dictionary(grouping: store.timelineEvents) { event in
            calendar.startOfDay(for: event.timestamp)
        }
        
        for (date, events) in grouped {
            // Get the last event of the day (most recent health)
            if let lastEvent = events.sorted(by: { $0.timestamp < $1.timestamp }).last {
                healthStates[date] = lastEvent.healthAfter
            }
        }
        
        return healthStates
    }
    
    private func groupedEvents() -> [(date: Date, events: [TimelineEvent])] {
        let calendar = Calendar.current

        // Only show events with messages
        let messageEvents = store.timelineEvents.filter { $0.message != nil }

        let grouped = Dictionary(grouping: messageEvents) { event in
            calendar.startOfDay(for: event.timestamp)
        }
        // Sort oldest first (welcome message at top, new entries at bottom)
        return grouped.sorted { $0.key < $1.key }.map { (date: $0.key, events: $0.value.sorted { $0.timestamp < $1.timestamp }) }
    }
}

// MARK: - Date Header View
struct DateHeaderView: View {
    let date: Date
    let isExpanded: Bool
    let onToggle: () -> Void
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onToggle()
            }
        }) {
            HStack(spacing: 8) {
                Circle()
                    .fill(DesignSystem.Colors.timelineIndicator)
                    .frame(width: 10, height: 10)
                
                Text(isToday ? "Today" : TimelineFeature.State.formattedDate(for: date))
                    .font(.custom("Sofia Pro-Semi_Bold", size: 16))
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                if !isToday {
                    Text("• \(TimelineFeature.State.formattedDayOfWeek(for: date))")
                        .font(.custom("Sofia Pro-Regular", size: 16))
                        .foregroundColor(DesignSystem.Colors.timelineSecondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primaryBlue)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isExpanded)
            }
        }
        .buttonStyle(PlainButtonStyle())
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
                        Text(formattedTime)
                            .font(DesignSystem.Typography.timelineTime())
                            .foregroundColor(catState.timeColor)
                        
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

#Preview{
    TimelineItemView(event: .init(timestamp: .distantPast, appName: "aa", healthBefore: 10, healthAfter: 10, cooldownStarted: .distantFuture, eventType: .aiGenerated))
}
