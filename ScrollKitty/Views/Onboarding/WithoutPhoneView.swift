import ComposableArchitecture
import SwiftUI

@Reducer
struct WithoutPhoneFeature {
    enum WithoutPhoneOption: String, CaseIterable, Equatable, RawRepresentable {
        case veryAnxious = "Very anxious"
        case littleUneasy = "A little uneasy"
        case mostlyFine = "Mostly fine"
        case totallyFine = "Totally fine"
    }

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

struct WithoutPhoneView: View {
    let store: StoreOf<WithoutPhoneFeature>

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
                    ProgressIndicator(currentStep: 4, totalSteps: 6)
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.horizontal, 16)


                // Title
                Text("How do you feel without\nyour phone?")
                    .largeTitleStyle()
                    .padding(.top, 40)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)

                // Options
                OptionSelector(
                    options: WithoutPhoneFeature.WithoutPhoneOption.allCases,
                    selectedOption: store.selectedOption,
                    onSelect: { option in
                        store.send(.optionSelected(option))
                    }
                )
                .padding(.horizontal, 16)

                Spacer()

                // Next Button
                PrimaryButton(title: "Next") {
                    store.send(.nextTapped)
                }
                .padding(.bottom, 32)
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
