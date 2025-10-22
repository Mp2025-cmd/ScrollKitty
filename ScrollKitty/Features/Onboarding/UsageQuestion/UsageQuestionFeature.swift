import ComposableArchitecture

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
