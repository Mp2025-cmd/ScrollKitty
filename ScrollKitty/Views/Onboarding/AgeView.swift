import ComposableArchitecture
import SwiftUI

@Reducer
struct AgeFeature {
    enum AgeOption: String, CaseIterable, Equatable, RawRepresentable {
        case under18 = "under 18"
        case age18to24 = "18 - 24yrs"
        case age25to34 = "25 - 34yrs"
        case age35to44 = "35 - 44yrs"
        case age45to54 = "45 - 54yrs"
        case age55plus = "55+yrs"
    }

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

struct AgeView: View {
    let store: StoreOf<AgeFeature>

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
                    ProgressIndicator(currentStep: 5, totalSteps: 5)
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.horizontal, 16)

                // Title
                Text("How old are you?")
                    .largeTitleStyle()
                    .padding(.top, 40)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)

                // Options
                OptionSelector(
                    options: AgeFeature.AgeOption.allCases,
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
    AgeView(
        store: Store(
            initialState: AgeFeature.State(),
            reducer: { AgeFeature() }
        )
    )
}
