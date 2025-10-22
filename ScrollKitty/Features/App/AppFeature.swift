import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var onboarding = OnboardingFeature.State()
        var isOnboardingComplete = false
        var userHourSelection: UsageQuestionFeature.HourOption?
    }
    
    enum Action {
        case onboarding(OnboardingFeature.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onboarding(.delegate(.onboardingCompleted(let hourSelection))):
                state.isOnboardingComplete = true
                state.userHourSelection = hourSelection
                return .none
                
            case .onboarding:
                return .none
            }
        }
        
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
    }
}
 
