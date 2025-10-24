import ComposableArchitecture
import SwiftUI

@Reducer
struct SleepFeature {
    enum SleepOption: String, CaseIterable, Equatable, RawRepresentable {
        case almostEveryNight = "Almost every night"
        case fewTimesWeek = "A few times a week"
        case rarely = "Rarely"
        case never = "Never"
    }

    @ObservableState
    struct State: Equatable {
        var selectedOption: SleepOption?
    }

    enum Action: Equatable {
        case optionSelected(SleepOption)
        case nextTapped
        case backTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case completeWithSelection(SleepOption)
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

struct SleepView: View {
    let store: StoreOf<SleepFeature>

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
                    ProgressIndicator(currentStep: 3, totalSteps: 6)
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.horizontal, 16)

                // Title
                Text("Does phone use interfere\nwith your sleep?")
                    .largeTitleStyle()
                    .padding(.top, 40)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)

                // Options
                OptionSelector(
                    options: SleepFeature.SleepOption.allCases,
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
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    SleepView(
        store: Store(
            initialState: SleepFeature.State(),
            reducer: { SleepFeature() }
        )
    )
}
