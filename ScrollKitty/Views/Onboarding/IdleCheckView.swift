import ComposableArchitecture
import SwiftUI

@Reducer
struct IdleCheckFeature {
    @ObservableState
    struct State: Equatable {
        var selectedOption: IdleCheckOption?
    }

    enum Action: Equatable {
        case optionSelected(IdleCheckOption)
        case nextTapped
        case backTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case completeWithSelection(IdleCheckOption)
            case goBack
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .optionSelected(let option):
                state.selectedOption = option
                return .none

            case .nextTapped:
                if let selectedOption = state.selectedOption {
                    return .send(.delegate(.completeWithSelection(selectedOption)))
                }
                return .none

            case .backTapped:
                return .send(.delegate(.goBack))

            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - View

struct IdleCheckView: View {
    let store: StoreOf<IdleCheckFeature>

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
                
                // Progress indicator
                ProgressIndicator(currentStep: 5, totalSteps: 6)
                    .padding(.top, 16)

                // Title
                Text("How often do you check\nyour phone when idle?")
                    .largeTitleStyle()
                    .padding(.top, 40)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 50)

                // Options
                OptionSelector(
                    options: IdleCheckOption.allCases,
                    selectedOption: store.selectedOption,
                    onSelect: { option in
                        store.send(.optionSelected(option))
                    }
                )
                .padding(.horizontal, 25)

                Spacer()

                // Next Button
                PrimaryButton(title: "Next", isEnabled: store.selectedOption != nil) {
                    store.send(.nextTapped)
                }
            }
        }
    }
}

#Preview {
    IdleCheckView(
        store: Store(
            initialState: IdleCheckFeature.State(),
            reducer: { IdleCheckFeature() }
        )
    )
}
