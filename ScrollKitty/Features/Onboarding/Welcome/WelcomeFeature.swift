import ComposableArchitecture

@Reducer
struct WelcomeFeature {
    @ObservableState
    struct State: Equatable {
        // No state needed for welcome screen
    }

    enum Action: Equatable {
        case getStartedTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case proceedToNextStep
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .getStartedTapped:
                return .send(.delegate(.proceedToNextStep))

            case .delegate:
                return .none
            }
        }
    }
}
