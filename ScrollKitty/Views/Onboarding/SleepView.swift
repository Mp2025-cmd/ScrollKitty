import ComposableArchitecture
import SwiftUI

@Reducer
struct SleepFeature {
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

struct SleepView: View {
    let store: StoreOf<SleepFeature>

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
                ProgressIndicator(currentStep: 3, totalSteps: 6)
                    .padding(.top, 16)

                // Title
                Text("Does phone use interfere\nwith your sleep?")
                    .largeTitleStyle()
                    .padding(.top, 40)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 50)

                // Options
                OptionSelector(
                    options: SleepOption.allCases,
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
    SleepView(
        store: Store(
            initialState: SleepFeature.State(),
            reducer: { SleepFeature() }
        )
    )
}
