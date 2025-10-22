import ComposableArchitecture
import SwiftUI

@Reducer
struct IdleCheckFeature {
    enum IdleCheckOption: String, CaseIterable, Equatable, RawRepresentable {
        case everyFewMinutes = "Every few minutes"
        case everyHour = "Every hour"
        case fewTimesDay = "A few times a day"
        case rarely = "Rarely"
    }

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

struct IdleCheckView: View {
    let store: StoreOf<IdleCheckFeature>

    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator with back button
                HStack(spacing: 16) {
                    Button(action: { store.send(.backTapped) }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.system(size: 18, weight: .semibold))
                    }

                    ProgressIndicator(currentStep: 5, totalSteps: 5)

                    Spacer()
                }
                .padding(.top, 24)
                .padding(.horizontal, 16)

                // Title
                Text("How often do you check\nyour phone when idle?")
                    .largeTitleStyle()
                    .padding(.top, 40)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)

                // Options
                OptionSelector(
                    options: IdleCheckFeature.IdleCheckOption.allCases,
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
    IdleCheckView(
        store: Store(
            initialState: IdleCheckFeature.State(),
            reducer: { IdleCheckFeature() }
        )
    )
}
