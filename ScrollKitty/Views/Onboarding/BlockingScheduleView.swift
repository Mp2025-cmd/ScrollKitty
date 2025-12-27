import ComposableArchitecture
import SwiftUI

// MARK: - Blocking Schedule Preset Feature

@Reducer
struct BlockingSchedulePresetFeature {
    enum Context: Equatable {
        case onboarding
        case settings
    }

    @ObservableState
    struct State: Equatable {
        var selectedPreset: BlockingPreset?
        var context: Context = .onboarding
    }

    enum Action: Equatable {
        case presetSelected(BlockingPreset)
        case nextTapped
        case backTapped
        case skipTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case continueToDetail(BlockingPreset)
            case goBack
            case skipForNow
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .presetSelected(let preset):
                state.selectedPreset = preset
                // Immediately navigate to detail view when preset is tapped
                return .send(.delegate(.continueToDetail(preset)))

            case .nextTapped:
                guard let preset = state.selectedPreset else { return .none }
                return .send(.delegate(.continueToDetail(preset)))

            case .backTapped:
                return .send(.delegate(.goBack))

            case .skipTapped:
                return .send(.delegate(.skipForNow))

            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - Blocking Schedule Detail Feature

@Reducer
struct BlockingScheduleDetailFeature {
    enum Context: Equatable {
        case onboarding
        case settings
    }

    @ObservableState
    struct State: Equatable {
        var schedule: BlockingSchedule
        var selectedDays: Set<Weekday>
        var startTime: Date
        var endTime: Date
        var context: Context

        init(preset: BlockingPreset, context: Context = .onboarding) {
            let schedule = BlockingSchedule.from(preset: preset)
            self.schedule = schedule
            self.selectedDays = schedule.selectedDays
            self.startTime = schedule.startTime
            self.endTime = schedule.endTime
            self.context = context
        }
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case dayToggled(Weekday)
        case startTimeChanged(Date)
        case endTimeChanged(Date)
        case nextTapped
        case backTapped
        case skipTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case completeWithSchedule(BlockingSchedule)
            case goBack
            case skipForNow
        }
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .dayToggled(let day):
                if state.selectedDays.contains(day) {
                    state.selectedDays.remove(day)
                } else {
                    state.selectedDays.insert(day)
                }
                return .none

            case .startTimeChanged(let time):
                state.startTime = time
                return .none

            case .endTimeChanged(let time):
                state.endTime = time
                return .none

            case .nextTapped:
                let finalSchedule = BlockingSchedule(
                    id: state.schedule.id,
                    name: state.schedule.name,
                    emoji: state.schedule.emoji,
                    startTime: state.startTime,
                    endTime: state.endTime,
                    selectedDays: state.selectedDays
                )
                return .send(.delegate(.completeWithSchedule(finalSchedule)))

            case .backTapped:
                return .send(.delegate(.goBack))

            case .skipTapped:
                return .send(.delegate(.skipForNow))

            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - Blocking Schedule Preset View

struct BlockingSchedulePresetView: View {
    let store: StoreOf<BlockingSchedulePresetFeature>

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
                    if store.context == .onboarding {
                        Button("Skip for now") {
                            store.send(.skipTapped)
                        }
                        .font(.custom("Sofia Pro-Regular", size: 14))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Title & Subtitle
                VStack(spacing: 12) {
                    Text("When should Scroll Kitty block your apps?")
                        .largeTitleStyle()
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Pick the time when you need the most focus and protection from distractions.")
                        .font(.custom("Sofia Pro-Regular", size: 16))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    Text("Skip for now and Scroll Kitty will keep shields off until you set this in Settings.")
                        .font(.custom("Sofia Pro-Regular", size: 14))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 40)
                .padding(.horizontal, 16)
                .padding(.bottom, 40)

                // Preset Options
                VStack(spacing: 25) {
                    ForEach(BlockingPreset.allCases, id: \.self) { preset in
                        PresetOptionButton(
                            preset: preset,
                            isSelected: store.selectedPreset == preset,
                            action: {
                                store.send(.presetSelected(preset))
                            }
                        )
                    }
                }
                .padding(.horizontal, 25)

                Spacer()
            }
        }
    }
}

// MARK: - Blocking Schedule Detail View

struct BlockingScheduleDetailView: View {
    @Bindable var store: StoreOf<BlockingScheduleDetailFeature>

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
                    if store.context == .onboarding {
                        Button("Skip for now") {
                            store.send(.skipTapped)
                        }
                        .font(.custom("Sofia Pro-Regular", size: 14))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Title & Subtitle
                VStack(spacing: 12) {
                    Text("Set up your blocking schedule")
                        .largeTitleStyle()
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Choose when your apps will be blocked each day.")
                        .font(.custom("Sofia Pro-Regular", size: 16))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    if store.context == .onboarding {
                        Text("Skip for now and Scroll Kitty will keep shields off until you set this in Settings.")
                            .font(.custom("Sofia Pro-Regular", size: 14))
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 40)
                .padding(.horizontal, 16)
                .padding(.bottom, 40)

                // Schedule Card
                VStack(alignment: .leading, spacing: 24) {
                    // Rule Name with Emoji
                    HStack(spacing: 10) {
                        Text(store.schedule.emoji)
                            .font(.system(size: 28))

                        Text(store.schedule.name)
                            .font(.custom("Sofia Pro-Semi_Bold", size: 20))
                            .foregroundColor(DesignSystem.Colors.primaryText)
                    }
                    .padding(.leading, 4)

                    Divider()
                        .background(Color.gray.opacity(0.3))

                    // Time Range
                    VStack(spacing: 16) {
                        TimeRangeRow(
                            label: "Starts",
                            time: $store.startTime
                        )

                        TimeRangeRow(
                            label: "Ends",
                            time: $store.endTime
                        )
                    }

                    Divider()
                        .background(Color.gray.opacity(0.3))

                    // Days Selector
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Days")
                            .font(.custom("Sofia Pro-Regular", size: 16))
                            .foregroundColor(DesignSystem.Colors.textGray)

                        WeekdaySelector(selectedDays: $store.selectedDays)
                    }
                }
                .padding(24)
                .background(Color(hex: "#F5F5F5"))
                .cornerRadius(20)
                .padding(.horizontal, 16)

                Spacer()

                // Next/Save Button (context-aware)
                PrimaryButton(
                    title: store.context == .settings ? "Save" : "Next",
                    isEnabled: !store.selectedDays.isEmpty
                ) {
                    store.send(.nextTapped)
                }
            }
        }
    }
}

// MARK: - Preset Option Button

private struct PresetOptionButton: View {
    let preset: BlockingPreset
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(preset.emoji)
                    .font(.system(size: 32))

                Text(preset.rawValue)
                    .font(.custom("Sofia Pro-Regular", size: 18))
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.ComponentSize.optionHeight)
            .background(DesignSystem.Colors.selectionBackground)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.selectionOption)
                    .stroke(
                        isSelected ? DesignSystem.Colors.selectionBorder : Color.clear,
                        lineWidth: isSelected ? DesignSystem.BorderWidth.selection : 0
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.selectionOption))
        }
    }
}

// MARK: - Time Range Row

private struct TimeRangeRow: View {
    let label: String
    @Binding var time: Date

    var body: some View {
        HStack {
            Text(label)
                .font(.custom("Sofia Pro-Regular", size: 16))
                .foregroundColor(DesignSystem.Colors.textGray)

            Spacer()

            DatePicker(
                "",
                selection: $time,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "en_US"))
        }
    }
}

// MARK: - Previews

#Preview("Preset Selection") {
    BlockingSchedulePresetView(
        store: Store(
            initialState: BlockingSchedulePresetFeature.State(),
            reducer: { BlockingSchedulePresetFeature() }
        )
    )
}

#Preview("Detail Configuration") {
    BlockingScheduleDetailView(
        store: Store(
            initialState: BlockingScheduleDetailFeature.State(preset: .beforeBed),
            reducer: { BlockingScheduleDetailFeature() }
        )
    )
}

// MARK: - Preview Wrapper for Testing Full Flow

@Reducer
private struct BlockingSchedulePreviewFeature {
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var preset = BlockingSchedulePresetFeature.State()

        init() {
            // Start with preset screen
        }
    }

    enum Action {
        case path(StackAction<Path.State, Path.Action>)
        case preset(BlockingSchedulePresetFeature.Action)
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Path {
        case detail(BlockingScheduleDetailFeature)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.preset, action: \.preset) {
            BlockingSchedulePresetFeature()
        }

        Reduce { state, action in
            switch action {
            case .preset(.delegate(.continueToDetail(let preset))):
                state.path.append(.detail(BlockingScheduleDetailFeature.State(preset: preset)))
                return .none

            case .path(.element(id: _, action: .detail(.delegate(.goBack)))):
                state.path.removeLast()
                return .none

            case .preset(.delegate(.goBack)):
                return .none

            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

private struct BlockingSchedulePreviewWrapper: View {
    @Bindable var store: StoreOf<BlockingSchedulePreviewFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            BlockingSchedulePresetView(
                store: store.scope(state: \.preset, action: \.preset)
            )
        } destination: { store in
            switch store.case {
            case .detail(let detailStore):
                BlockingScheduleDetailView(store: detailStore)
            }
        }
    }
}

#Preview("Full Flow with Navigation") {
    BlockingSchedulePreviewWrapper(
        store: Store(
            initialState: BlockingSchedulePreviewFeature.State(),
            reducer: { BlockingSchedulePreviewFeature() }
        )
    )
}
