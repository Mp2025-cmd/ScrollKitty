import SwiftUI
import ComposableArchitecture
import Foundation
import FamilyControls

@Reducer
struct SettingsFeature {
	    @ObservableState
	    struct State: Equatable {
	        var screenTimeGoal: Int = 1 // hours (1-8)
	        var areAllAppsDisabled: Bool = false
	        var currentBlockingSchedule: BlockingSchedule?
	        var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
	        var isAppPickerPresented: Bool = false

	        @Presents var deleteConfirmation: AlertState<Action.Alert>?
	        var blockingSchedulePath = StackState<BlockingSchedulePath.State>()
	    }

    @Reducer(state: .equatable, action: .equatable)
    enum BlockingSchedulePath {
        case preset(BlockingSchedulePresetFeature)
        case detail(BlockingScheduleDetailFeature)
    }

			    enum Action: BindableAction {
			        case binding(BindingAction<State>)
			        case onAppear
			        case blockingScheduleLoaded(BlockingSchedule?)
			        case selectedAppsLoaded(FamilyActivitySelection)
			        case selectAppsTapped
			        case editBlockingScheduleTapped
			        case blockingSchedulePath(StackAction<BlockingSchedulePath.State, BlockingSchedulePath.Action>)
			        case deleteAllDataTapped
			        case alert(PresentationAction<Alert>)
			        case helpTapped
			        case featureRequestsTapped
			        case leaveReviewTapped
			        case contactUsTapped
			        case dismissTapped

		        enum Alert: Equatable {
		            case confirmDelete
		            case cancelDelete
		        }
			    }

	    @Dependency(\.userSettings) var userSettings
	    @Dependency(\.screenTimeManager) var screenTimeManager

	    var body: some Reducer<State, Action> {
	        BindingReducer()

	        Reduce { state, action in
            switch action {
	            case .onAppear:
	                return .run { send in
	                    let schedule = await userSettings.loadBlockingSchedule()
	                    await send(.blockingScheduleLoaded(schedule))
	                    let selection = await userSettings.loadSelectedApps() ?? FamilyActivitySelection()
	                    await send(.selectedAppsLoaded(selection))
	                }

	            case .blockingScheduleLoaded(let schedule):
	                state.currentBlockingSchedule = schedule
	                return .none
	                
	            case .selectedAppsLoaded(let selection):
	                state.selectedApps = selection
	                return .none

		            case .binding:
		                if !state.isAppPickerPresented {
		                    let selection = state.selectedApps
		                    return .run { [userSettings, screenTimeManager] _ in
		                        await userSettings.saveSelectedApps(selection)
		                        await screenTimeManager.applyShields()
		                        try? await screenTimeManager.startMonitoring()
		                    }
		                }
		                return .none

		            case .selectAppsTapped:
		                state.isAppPickerPresented = true
		                return .none

	            case .editBlockingScheduleTapped:
	                state.blockingSchedulePath.append(.preset(BlockingSchedulePresetFeature.State(context: .settings)))
	                return .none

            case .blockingSchedulePath(.element(id: _, action: .preset(.delegate(.continueToDetail(let preset))))):
                state.blockingSchedulePath.append(.detail(BlockingScheduleDetailFeature.State(preset: preset, context: .settings)))
                return .none

	            case .blockingSchedulePath(.element(id: _, action: .detail(.delegate(.completeWithSchedule(let schedule))))):
	                state.currentBlockingSchedule = schedule
	                state.blockingSchedulePath = StackState()
	                return .run { [userSettings, screenTimeManager] _ in
	                    await userSettings.saveBlockingSchedule(schedule)
	                    try? await screenTimeManager.startMonitoring()
	                }

	            case .blockingSchedulePath(.element(id: _, action: .preset(.delegate(.goBack)))),
	                 .blockingSchedulePath(.element(id: _, action: .detail(.delegate(.goBack)))):
	                if !state.blockingSchedulePath.isEmpty {
                    state.blockingSchedulePath.removeLast()
                }
                return .none

            case .blockingSchedulePath:
                return .none

            case .deleteAllDataTapped:
                state.deleteConfirmation = AlertState {
                    TextState("Delete All Data?")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmDelete) {
                        TextState("Delete")
                    }
                    ButtonState(role: .cancel, action: .cancelDelete) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("This will permanently delete all your data, including timeline history, settings, and preferences. This action cannot be undone.")
                }
                return .none

            case .alert(.presented(.confirmDelete)):
                state.screenTimeGoal = 1
                state.areAllAppsDisabled = false
                return .none

	            case .alert(.presented(.cancelDelete)):
	                return .none

	            case .alert(.dismiss):
	                return .none

	            case .helpTapped, .featureRequestsTapped, .leaveReviewTapped, .contactUsTapped:
	                return .none

            case .dismissTapped:
                return .none
            }
        }
        .ifLet(\.$deleteConfirmation, action: \.alert)
        .forEach(\.blockingSchedulePath, action: \.blockingSchedulePath)
    }
}

struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.blockingSchedulePath, action: \.blockingSchedulePath)) {
            content
        } destination: { store in
            switch store.case {
            case .preset(let presetStore):
                BlockingSchedulePresetView(store: presetStore)
            case .detail(let detailStore):
                BlockingScheduleDetailView(store: detailStore)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }

    @ViewBuilder
    private var content: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Spacer()

                        Button {
                            store.send(.dismissTapped)
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.primaryText)
                                .frame(width: 32, height: 32)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Title
                    Text("Settings")
                        .font(.custom("Sofia Pro-Bold", size: 32))
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 30)

                    // Screen Time Goal Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Screen Time Goal")
                            .font(.custom("Sofia Pro-Semi_Bold", size: 18))
                            .foregroundColor(DesignSystem.Colors.primaryText)

                        ScreenTimeGoalSlider(value: $store.screenTimeGoal)
                    }
                    .padding(20)
                    .background(DesignSystem.Colors.lightBlue)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                    // App Management Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("App Management")
                            .font(.custom("Sofia Pro-Semi_Bold", size: 18))
                            .foregroundColor(DesignSystem.Colors.primaryText)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 16)

	                        // Select Apps to Block
	                        Button {
	                            store.send(.selectAppsTapped)
	                        } label: {
	                            HStack {
	                                Image(systemName: "app.badge")
                                    .font(.system(size: 20))
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                    .frame(width: 24)

                                Text("Select Apps to Block")
                                    .font(.custom("Sofia Pro-Regular", size: 16))
                                    .foregroundColor(DesignSystem.Colors.primaryText)

	                                Spacer()
	                                
	                                let selectionCount = store.selectedApps.applicationTokens.count + store.selectedApps.categoryTokens.count
	                                Text(selectionCount > 0 ? "\(selectionCount) selected" : "None")
	                                    .font(.custom("Sofia Pro-Regular", size: 14))
	                                    .foregroundColor(DesignSystem.Colors.secondaryText)

	                                Image(systemName: "chevron.right")
	                                    .font(.system(size: 14, weight: .semibold))
	                                    .foregroundColor(DesignSystem.Colors.secondaryText)
	                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }

                        Divider()
                            .padding(.leading, 64)
                            .padding(.trailing, 20)

                        // Disable All Apps Toggle
                        Toggle(isOn: $store.areAllAppsDisabled) {
                            HStack(spacing: 16) {
                                Image(systemName: "hand.raised.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                    .frame(width: 24)

                                Text("Disable All Blocked Apps")
                                    .font(.custom("Sofia Pro-Regular", size: 16))
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.green))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .background(DesignSystem.Colors.lightBlue)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                    // Blocking Schedule Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Blocking Schedule")
                            .font(.custom("Sofia Pro-Semi_Bold", size: 18))
                            .foregroundColor(DesignSystem.Colors.primaryText)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 16)

                        // Edit Blocking Schedule
                        Button {
                            store.send(.editBlockingScheduleTapped)
                        } label: {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Edit Blocking Schedule")
                                        .font(.custom("Sofia Pro-Regular", size: 16))
                                        .foregroundColor(DesignSystem.Colors.primaryText)

                                    if let schedule = store.currentBlockingSchedule {
                                        Text("\(schedule.name) • \(formatTime(schedule.startTime)) - \(formatTime(schedule.endTime))")
                                            .font(.custom("Sofia Pro-Regular", size: 14))
                                            .foregroundColor(DesignSystem.Colors.secondaryText)
                                    } else {
                                        Text("Not set")
                                            .font(.custom("Sofia Pro-Regular", size: 14))
                                            .foregroundColor(DesignSystem.Colors.secondaryText)
                                    }
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                    }
                    .background(DesignSystem.Colors.lightBlue)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                    // Data Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Data")
                            .font(.custom("Sofia Pro-Semi_Bold", size: 18))
                            .foregroundColor(DesignSystem.Colors.primaryText)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 16)

                        // Delete All Data
                        Button {
                            store.send(.deleteAllDataTapped)
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.red)
                                    .frame(width: 24)

                                Text("Delete All Data")
                                    .font(.custom("Sofia Pro-Regular", size: 16))
                                    .foregroundColor(.red)

                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                    }
                    .background(DesignSystem.Colors.lightBlue)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                    // Support & Feedback Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Support & Feedback")
                            .font(.custom("Sofia Pro-Semi_Bold", size: 18))
                            .foregroundColor(DesignSystem.Colors.primaryText)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 16)

                        // Help & Support
                        Button {
                            store.send(.helpTapped)
                        } label: {
                            SettingsRow(
                                icon: "questionmark.circle.fill",
                                title: "Help & Support"
                            )
                        }

                        Divider()
                            .padding(.leading, 64)
                            .padding(.trailing, 20)

                        // Feature requests
                        Button {
                            store.send(.featureRequestsTapped)
                        } label: {
                            SettingsRow(
                                icon: "lightbulb.fill",
                                title: "Feature requests"
                            )
                        }

                        Divider()
                            .padding(.leading, 64)
                            .padding(.trailing, 20)

                        // Leave a review
                        Button {
                            store.send(.leaveReviewTapped)
                        } label: {
                            SettingsRow(
                                icon: "star.fill",
                                title: "Leave a review"
                            )
                        }

                        Divider()
                            .padding(.leading, 64)
                            .padding(.trailing, 20)

                        // Contact us
                        Button {
                            store.send(.contactUsTapped)
                        } label: {
                            SettingsRow(
                                icon: "envelope.fill",
                                title: "Contact us",
                                showChevron: false
                            )
                        }
                    }
                    .background(DesignSystem.Colors.lightBlue)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
	        }
	        .alert($store.scope(state: \.deleteConfirmation, action: \.alert))
	        .sheet(isPresented: $store.isAppPickerPresented) {
	            NavigationView {
	                FamilyActivityPicker(selection: $store.selectedApps)
	                    .navigationTitle("Select Apps")
	                    .navigationBarTitleDisplayMode(.inline)
	                    .toolbar {
	                        ToolbarItem(placement: .navigationBarLeading) {
	                            Button("Clear") {
	                                store.selectedApps = FamilyActivitySelection()
	                            }
	                        }
		                        ToolbarItem(placement: .navigationBarTrailing) {
		                            Button("Done") {
		                                store.isAppPickerPresented = false
		                            }
		                        }
		                    }
		            }
		        }
		    }
		}

// MARK: - Screen Time Goal Slider

private struct ScreenTimeGoalSlider: View {
    @Binding var value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(value)h")
                    .font(.custom("Sofia Pro-Semi_Bold", size: 24))
                    .foregroundColor(DesignSystem.Colors.primaryText)

                Spacer()

                Text("Daily Goal")
                    .font(.custom("Sofia Pro-Regular", size: 14))
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }

            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0) }
                ),
                in: 1...8,
                step: 1
            )
            .tint(DesignSystem.Colors.green)

            HStack {
                Text("1h")
                    .font(.custom("Sofia Pro-Regular", size: 12))
                    .foregroundColor(DesignSystem.Colors.secondaryText)

                Spacer()

                Text("8h")
                    .font(.custom("Sofia Pro-Regular", size: 12))
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
    }
}

// MARK: - Settings Row

private struct SettingsRow: View {
    let icon: String
    let title: String
    var showChevron: Bool = true

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(DesignSystem.Colors.primaryText)
                .frame(width: 24)

            Text(title)
                .font(.custom("Sofia Pro-Regular", size: 16))
                .foregroundColor(DesignSystem.Colors.primaryText)

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Helper Functions

private func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

// MARK: - Preview

#Preview {
    SettingsView(
        store: Store(
            initialState: SettingsFeature.State(),
            reducer: { SettingsFeature() }
        )
    )
}
