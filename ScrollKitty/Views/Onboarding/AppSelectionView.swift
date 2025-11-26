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
    }

    enum Action: Equatable {
        case appsSelected(FamilyActivitySelection)
        case nextTapped
        case backTapped
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
                state.selectedApps = selection
                return .none

            case .nextTapped:
                return .send(.delegate(.completeWithSelection(state.selectedApps)))

            case .backTapped:
                return .send(.delegate(.goBack))

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

                // Title
                VStack(spacing: 8) {
                    Text("Which apps drain")
                    Text("your energy?")
                }
                .largeTitleStyle()
                .padding(.top, 40)
                .padding(.horizontal, 16)
                .padding(.bottom, 40)

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

