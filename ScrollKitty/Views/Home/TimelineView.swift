import SwiftUI
import AVFAudio
import ComposableArchitecture

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
                
                // AI Unavailable Notice (one-time)
                if store.showAIUnavailableNotice && !store.hasShownAINotice {
                    AIUnavailableNoticeView {
                        store.send(.dismissAINotice)
                    }
                    .padding(.horizontal, 34)
                    .padding(.bottom, 12)
                }
                
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
                                    DateHeaderView(date: group.date)
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
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    private func groupedEvents() -> [(date: Date, events: [TimelineEvent])] {
        let calendar = Calendar.current

        // Only show events with AI messages
        let aiEvents = store.timelineEvents.filter { $0.aiMessage != nil }

        let grouped = Dictionary(grouping: aiEvents) { event in
            calendar.startOfDay(for: event.timestamp)
        }
        // Sort oldest first (welcome message at top, new entries at bottom)
        return grouped.sorted { $0.key < $1.key }.map { (date: $0.key, events: $0.value.sorted { $0.timestamp < $1.timestamp }) }
    }
}

// MARK: - Date Header View
struct DateHeaderView: View {
    let date: Date
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(DesignSystem.Colors.timelineIndicator)
                .frame(width: 10, height: 10)
            
            Text(formattedDate())
                .font(.custom("Sofia Pro-Semi_Bold", size: 16))
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            Text("• \(formattedDayOfWeek())")
                .font(.custom("Sofia Pro-Regular", size: 16))
                .foregroundColor(DesignSystem.Colors.timelineSecondaryText)
            Spacer()
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func formattedDayOfWeek() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
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

// MARK: - AI Unavailable Notice View
struct AIUnavailableNoticeView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.blue)
            
            Text("On this device, I use my simpler built-in notes instead of my full brain.")
                .font(.custom("Sofia Pro-Regular", size: 13))
                .foregroundColor(DesignSystem.Colors.primaryText)
                .lineLimit(nil)
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.timelineSecondaryText)
            }
        }
        .padding(12)
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
        guard let aiMessage = event.aiMessage else { return "" }
        if let emoji = event.aiEmoji {
            return "\(aiMessage) \(emoji)"
        }
        return aiMessage
    }
}

#Preview{
    TimelineItemView(event: .init(timestamp: .distantPast, appName: "aa", healthBefore: 10, healthAfter: 10, cooldownStarted: .distantFuture, eventType: .aiGenerated))
}
