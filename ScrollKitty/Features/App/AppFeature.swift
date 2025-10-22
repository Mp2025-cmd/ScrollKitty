import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var onboarding = OnboardingFeature.State()
        var isOnboardingComplete = false
        var userHourSelection: UsageQuestionFeature.HourOption?
        var userAddictionSelection: AddictionFeature.AddictionOption?
        var userSleepSelection: SleepFeature.SleepOption?
        var userWithoutPhoneSelection: WithoutPhoneFeature.WithoutPhoneOption?
        var userIdleCheckSelection: IdleCheckFeature.IdleCheckOption?
        var userAgeSelection: AgeFeature.AgeOption?
    }

    enum Action {
        case onboarding(OnboardingFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onboarding(.delegate(.onboardingCompleted(
                let hourSelection,
                let addictionSelection,
                let sleepSelection,
                let withoutPhoneSelection,
                let idleCheckSelection,
                let ageSelection
            ))):
                state.isOnboardingComplete = true
                state.userHourSelection = hourSelection
                state.userAddictionSelection = addictionSelection
                state.userSleepSelection = sleepSelection
                state.userWithoutPhoneSelection = withoutPhoneSelection
                state.userIdleCheckSelection = idleCheckSelection
                state.userAgeSelection = ageSelection
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
 
