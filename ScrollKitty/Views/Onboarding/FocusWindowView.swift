import ComposableArchitecture
import SwiftUI

struct FocusWindowData: Equatable, Codable {
    var startTime: Date
    var endTime: Date
    var selectedDays: Set<Int> // 1 = Sunday, 2 = Monday, etc.
}

enum DayOption: String, CaseIterable, Equatable, RawRepresentable, Hashable {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    
    var calendarIndex: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
    
    static func from(index: Int) -> DayOption? {
        return DayOption.allCases.first { $0.calendarIndex == index }
    }
}

@Reducer
struct FocusWindowFeature {
    @ObservableState
    struct State: Equatable {
        var startTime: Date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) ?? Date()
        var endTime: Date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date()) ?? Date()
        var selectedDays: Set<Int> = Set(1...7) // Default all days
        
        // Computed property to map Set<Int> to Set<DayOption> for the view
        var selectedDayOptions: Set<DayOption> {
            get {
                Set(selectedDays.compactMap { DayOption.from(index: $0) })
            }
            set {
                selectedDays = Set(newValue.map { $0.calendarIndex })
            }
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case dayToggled(DayOption)
        case nextTapped
        case backTapped
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case completeWithSelection(FocusWindowData)
            case goBack
        }
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .dayToggled(let dayOption):
                let dayIndex = dayOption.calendarIndex
                if state.selectedDays.contains(dayIndex) {
                    // Prevent deselecting the last day
                    if state.selectedDays.count > 1 {
                        state.selectedDays.remove(dayIndex)
                    }
                } else {
                    state.selectedDays.insert(dayIndex)
                }
                return .none
                
            case .nextTapped:
                let data = FocusWindowData(
                    startTime: state.startTime,
                    endTime: state.endTime,
                    selectedDays: state.selectedDays
                )
                return .send(.delegate(.completeWithSelection(data)))
                
            case .backTapped:
                return .send(.delegate(.goBack))
                
            case .binding:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

struct FocusWindowView: View {
    @Bindable var store: StoreOf<FocusWindowFeature>
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button
                HStack {
                    BackButton {
                        store.send(.backTapped)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // ScrollView for content in case vertical space is tight
                ScrollView {
                    VStack(spacing: 0) {
                        // Title
                        Text("When should Scroll Kitty protect you?")
                            .largeTitleStyle()
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 30)
                        
                        // Time Selection
                        VStack(spacing: 24) {
                            HStack {
                                Text("Start Time")
                                    .font(.custom("Sofia Pro-Medium", size: 18))
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                
                                Spacer()
                                
                                DatePicker("", selection: $store.startTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .accentColor(DesignSystem.Colors.primaryBlue)
                            }
                            .padding(.horizontal, 24)
                            
                            HStack {
                                Text("End Time")
                                    .font(.custom("Sofia Pro-Medium", size: 18))
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                
                                Spacer()
                                
                                DatePicker("", selection: $store.endTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .accentColor(DesignSystem.Colors.primaryBlue)
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 30)
                        
                        // Day Selection using OptionSelector
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Active Days")
                                .font(.custom("Sofia Pro-Medium", size: 18))
                                .foregroundColor(DesignSystem.Colors.primaryText)
                                .padding(.horizontal, 24)
                            
                            OptionSelector(
                                options: DayOption.allCases,
                                selectedOptions: store.selectedDayOptions,
                                onToggle: { dayOption in
                                    store.send(.dayToggled(dayOption))
                                }
                            )
                            .padding(.horizontal, 25)
                        }
                        
                        SizedBox(height: 100) // Spacer for scrolling
                    }
                }
                
                Spacer()
                
                // Next Button (Fixed at bottom)
                VStack {
                    Spacer()
                    PrimaryButton(title: "Next") {
                        store.send(.nextTapped)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

// Helper for spacing
struct SizedBox: View {
    let height: CGFloat
    var body: some View {
        Color.clear.frame(height: height)
    }
}

#Preview {
    FocusWindowView(
        store: Store(
            initialState: FocusWindowFeature.State(),
            reducer: { FocusWindowFeature() }
        )
    )
}
