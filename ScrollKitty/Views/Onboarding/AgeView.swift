import ComposableArchitecture
import SwiftUI

@Reducer
struct AgeFeature {
    @ObservableState
    struct State: Equatable {
        var selectedOption: AgeOption?
    }

    enum Action: Equatable {
        case optionSelected(AgeOption)
        case nextTapped
        case backTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case completeWithSelection(AgeOption)
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

struct AgeView: View {
    let store: StoreOf<AgeFeature>

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
                ProgressIndicator(currentStep: 6, totalSteps: 6)
                    .padding(.top, 16)

                // Title
                Text("How old are you?")
                    .largeTitleStyle()
                    .padding(.top, 40)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)

                // Options
                OptionSelector(
                    options: AgeOption.allCases,
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
    AgeView(
        store: Store(
            initialState: AgeFeature.State(),
            reducer: { AgeFeature() }
        )
    )
}
