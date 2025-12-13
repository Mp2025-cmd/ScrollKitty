import ComposableArchitecture
import SwiftUI

@Reducer
struct UsageQuestionFeature {
    @ObservableState
    struct State: Equatable {
        var selectedOption: HourOption?
    }

    enum Action: Equatable {
        case optionSelected(HourOption)
        case nextTapped
        case backTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case completeWithSelection(HourOption)
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

struct UsageQuestionView: View {
    let store: StoreOf<UsageQuestionFeature>
    
    var body: some View {
        ZStack {
            // White background
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
                ProgressIndicator(currentStep: 1, totalSteps: 6)
                    .padding(.top, 16)
                
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
                    options: HourOption.allCases,
                    selectedOption: store.selectedOption,
                    onSelect: { option in
                        store.send(.optionSelected(option))
                    }
                )
                .padding(.horizontal, 25)
                
                Spacer()
                
                 PrimaryButton(title: "Next", isEnabled: store.selectedOption != nil) {
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
