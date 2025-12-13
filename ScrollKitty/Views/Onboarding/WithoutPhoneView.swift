import ComposableArchitecture
import SwiftUI

@Reducer
struct WithoutPhoneFeature {
    @ObservableState
    struct State: Equatable {
        var selectedOption: WithoutPhoneOption?
    }

    enum Action: Equatable {
        case optionSelected(WithoutPhoneOption)
        case nextTapped
        case backTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case completeWithSelection(WithoutPhoneOption)
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

struct WithoutPhoneView: View {
    let store: StoreOf<WithoutPhoneFeature>

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
                ProgressIndicator(currentStep: 4, totalSteps: 6)
                    .padding(.top, 16)


                // Title
                Text("How do you feel without\nyour phone?")
                    .largeTitleStyle()
                    .padding(.top, 40)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)

                // Options
                OptionSelector(
                    options: WithoutPhoneOption.allCases,
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
    WithoutPhoneView(
        store: Store(
            initialState: WithoutPhoneFeature.State(),
            reducer: { WithoutPhoneFeature() }
        )
    )
}
