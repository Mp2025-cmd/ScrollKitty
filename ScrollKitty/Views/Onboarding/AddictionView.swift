import ComposableArchitecture
import SwiftUI

@Reducer
struct AddictionFeature {
    enum AddictionOption: String, CaseIterable, Equatable, RawRepresentable {
        case yes = "Yes"
        case often = "Often"
        case sometimes = "Sometimes"
        case rarely = "Rarely"
        case notAtAll = "Not at all"
    }

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
            case backPressed
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
                return .send(.delegate(.backPressed))

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
                // Progress indicator with back button
                HStack {
                    Button(action: { store.send(.backTapped) }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    

                    Spacer()
                    ProgressIndicator(currentStep: 2, totalSteps: 6)
                    Spacer()
                    //
                }
                .padding(.top, 24)
                .padding(.horizontal, 16)

                // Title
                Text("Do you feel addicted\nto your phone?")
                    .largeTitleStyle()
                    .padding(.top, 40)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 65)

                // Options
                OptionSelector(
                    options: AddictionFeature.AddictionOption.allCases,
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
