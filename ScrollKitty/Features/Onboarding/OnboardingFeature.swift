import ComposableArchitecture

@Reducer
struct OnboardingFeature {
    @ObservableState
    struct State: Equatable {
        var splash = SplashFeature.State()
        var path = StackState<Path.State>()
    }
    
    enum Action: Equatable {
        case splash(SplashFeature.Action)
        case path(StackAction<Path.State, Path.Action>)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case onboardingCompleted(hourSelection: UsageQuestionFeature.HourOption)
        }
    }
    
    @Reducer(state: .equatable, action: .equatable)
    enum Path {
        case welcome(WelcomeFeature)
        case usageQuestion(UsageQuestionFeature)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .splash(.delegate(.splashCompleted)):
                state.path.append(.welcome(WelcomeFeature.State()))
                return .none
                
            case .path(.element(id: _, action: .welcome(.delegate(.proceedToNextStep)))):
                state.path.append(.usageQuestion(UsageQuestionFeature.State()))
                return .none
                
            case .path(.element(id: _, action: .usageQuestion(.delegate(.completeWithSelection(let selection))))):
                return .send(.delegate(.onboardingCompleted(hourSelection: selection)))
                
            case .splash:
                return .none
                
            case .path:
                return .none
                
            case .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        
        Scope(state: \.splash, action: \.splash) {
            SplashFeature()
        }
    }
}
