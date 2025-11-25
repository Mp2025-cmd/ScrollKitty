import ComposableArchitecture
import SwiftUI
import FamilyControls

// Make FamilyActivitySelection conform to Equatable
extension FamilyActivitySelection: Equatable {
    public static func == (lhs: FamilyActivitySelection, rhs: FamilyActivitySelection) -> Bool {
        // Compare by encoding to data
        let encoder = JSONEncoder()
        guard let lhsData = try? encoder.encode(lhs),
              let rhsData = try? encoder.encode(rhs) else {
            return false
        }
        return lhsData == rhsData
    }
}

@Reducer
struct AppSelectionFeature {
    @ObservableState
    struct State: Equatable {
        var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
        var showingLimitAlert = false

        var appCount: Int {
            selectedApps.applicationTokens.count
        }

        var canSelectMore: Bool {
            appCount < 10
        }

        var limitWarning: String? {
            if appCount >= 10 {
                return "Maximum 10 apps selected"
            } else if appCount >= 8 {
                return "\(10 - appCount) slots remaining"
            }
            return nil
        }
    }

    enum Action: Equatable {
        case appsSelected(FamilyActivitySelection)
        case nextTapped
        case backTapped
        case dismissAlert
        case delegate(Delegate)

        enum Delegate: Equatable {
            case completeWithSelection(FamilyActivitySelection)
            case goBack
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .appsSelected(let selection):
                // Enforce 10-app limit
                if selection.applicationTokens.count > 10 {
                    state.showingLimitAlert = true
                    return .none
                }
                state.selectedApps = selection
                return .none

            case .nextTapped:
                // Require at least 1 app
                guard state.appCount > 0 else {
                    state.showingLimitAlert = true
                    return .none
                }
                return .send(.delegate(.completeWithSelection(state.selectedApps)))

            case .backTapped:
                return .send(.delegate(.goBack))

            case .dismissAlert:
                state.showingLimitAlert = false
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - View

struct AppSelectionView: View {
    let store: StoreOf<AppSelectionFeature>

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

                // Title with app counter
                VStack(spacing: 8) {
                    Text("Which apps drain")
                    Text("your energy?")
                }
                .largeTitleStyle()
                .padding(.top, 40)
                .padding(.horizontal, 16)

                // App counter and limit warning
                HStack {
                    Text("Selected: \(store.appCount)/10 apps")
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.7))

                    Spacer()

                    if let warning = store.limitWarning {
                        Text(warning)
                            .font(.system(size: 12, weight: .semibold, design: .default))
                            .foregroundColor(store.appCount >= 10 ? .red : .orange)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Family Activity Picker
                FamilyActivityPicker(selection: Binding(
                    get: { store.selectedApps },
                    set: { store.send(.appsSelected($0)) }
                ))
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 16)

                Spacer()

                // Next Button
                PrimaryButton(title: "Next") {
                    store.send(.nextTapped)
                }
            }
        }
        .alert(
            "Selection Limit",
            isPresented: Binding(
                get: { store.showingLimitAlert },
                set: { _ in store.send(.dismissAlert) }
            )
        ) {
            Button("OK", role: .cancel) {
                store.send(.dismissAlert)
            }
        } message: {
            if store.appCount == 0 {
                Text("Please select at least 1 app to protect your time.")
            } else {
                Text("You can select a maximum of 10 apps. This ensures each app gets a meaningful health allocation.")
            }
        }
    }
}

#Preview {
    AppSelectionView(
        store: Store(
            initialState: AppSelectionFeature.State(),
            reducer: { AppSelectionFeature() }
        )
    )
}

