import ComposableArchitecture
import SwiftUI
import FamilyControls

// Make FamilyActivitySelection conform to Equatable
extension FamilyActivitySelection {
    public static func == (lhs: FamilyActivitySelection, rhs: FamilyActivitySelection) -> Bool {
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
        var isPickerPresented: Bool = false
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case selectAppsTapped
        case nextTapped
        case backTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case completeWithSelection(FamilyActivitySelection)
            case goBack
        }
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .selectAppsTapped:
                state.isPickerPresented = true
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
    @Bindable var store: StoreOf<AppSelectionFeature>
    
    private var selectionCount: Int {
        store.selectedApps.applicationTokens.count + store.selectedApps.categoryTokens.count
    }

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

                // Select Apps Button
                Button(action: { store.isPickerPresented = true }) {
                    HStack {
                        Text("Select Apps")
                            .font(.custom("Sofia Pro-Medium", size: 18))
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        
                        Spacer()
                        
                        Text(selectionCount > 0 ? "\(selectionCount) selected" : "None")
                            .font(.custom("Sofia Pro-Regular", size: 16))
                            .foregroundColor(DesignSystem.Colors.textGray)
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(DesignSystem.Colors.textGray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(DesignSystem.Colors.selectionBackground)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 25)

                Spacer()

                // Next Button
                PrimaryButton(title: "Next", isEnabled: selectionCount > 0) {
                    store.send(.nextTapped)
                }
            }
        }
        .sheet(isPresented: $store.isPickerPresented) {
            NavigationView {
                FamilyActivityPicker(selection: $store.selectedApps)
                    .navigationTitle("Select Apps")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                store.isPickerPresented = false
                            }
                        }
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
