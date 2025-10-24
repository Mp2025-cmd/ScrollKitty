import ComposableArchitecture
import SwiftUI

@Reducer
struct UsageQuestionFeature {
    enum HourOption: String, CaseIterable, Equatable {
        case threeOrLess = "3hrs or less"
        case threeToFive = "3hrs - 5hrs"
        case sixToEight = "6hrs - 8hrs"
        case nineToEleven = "9hrs - 11hrs"
        case twelveOrMore = "12hrs+"
    }

    @ObservableState
    struct State: Equatable {
        var selectedOption: HourOption?
    }

    enum Action: Equatable {
        case optionSelected(HourOption)
        case nextTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case completeWithSelection(HourOption)
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

            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - View

struct UsageQuestionView: View {
    let store: StoreOf<UsageQuestionFeature>
    
    var body: some View {
        ZStack {
            // White background
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                ProgressIndicator(currentStep: 1, totalSteps: 6)
                    .padding(.top, 24)
                
                // Title
                VStack(spacing: 8) {
                    Text("How many hours do you")
                    Text("spend on your phone")
                    Text("each day?")
                }
                .largeTitleStyle()
                .padding(.top, 40)
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
                
                // Options
                OptionSelector(
                    options: UsageQuestionFeature.HourOption.allCases,
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
    UsageQuestionView(
        store: Store(
            initialState: UsageQuestionFeature.State(),
            reducer: { UsageQuestionFeature() }
        )
    )
}
