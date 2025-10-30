import ComposableArchitecture
import SwiftUI

@Reducer
struct AddictionFeature {
    @ObservableState
    struct State: Equatable {
        var selectedOption: AddictionOption?
    }

    enum Action: Equatable {
        case optionSelected(AddictionOption)
        case nextTapped
        case backTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case completeWithSelection(AddictionOption)
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

struct AddictionView: View {
    let store: StoreOf<AddictionFeature>

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
                ProgressIndicator(currentStep: 2, totalSteps: 6)
                    .padding(.top, 16)
                .padding(.horizontal, 16)

                // Title
                Text("Do you feel addicted\nto your phone?")
                    .largeTitleStyle()
                    .padding(.top, 40)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 65)

                // Options
                OptionSelector(
                    options: AddictionOption.allCases,
                    selectedOption: store.selectedOption,
                    onSelect: { option in
                        store.send(.optionSelected(option))
                    }
                )
                .padding(.horizontal, 25)

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
    AddictionView(
        store: Store(
            initialState: AddictionFeature.State(),
            reducer: { AddictionFeature() }
        )
    )
}
