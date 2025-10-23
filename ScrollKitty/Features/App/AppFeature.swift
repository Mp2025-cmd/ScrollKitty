import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var onboarding = OnboardingFeature.State()
        var resultsLoading = ResultsLoadingFeature.State()
        var results = ResultsFeature.State()
        var addictionScore = AddictionScoreFeature.State()
        var isOnboardingComplete = false
        var showResultsLoading = false
        var showResults = false
        var showAddictionScore = false
        var userHourSelection: UsageQuestionFeature.HourOption?
        var userAddictionSelection: AddictionFeature.AddictionOption?
        var userSleepSelection: SleepFeature.SleepOption?
        var userWithoutPhoneSelection: WithoutPhoneFeature.WithoutPhoneOption?
        var userIdleCheckSelection: IdleCheckFeature.IdleCheckOption?
        var userAgeSelection: AgeFeature.AgeOption?
    }

    enum Action {
        case onboarding(OnboardingFeature.Action)
        case resultsLoading(ResultsLoadingFeature.Action)
        case results(ResultsFeature.Action)
        case addictionScore(AddictionScoreFeature.Action)
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
                state.showResultsLoading = true
                state.userHourSelection = hourSelection
                state.userAddictionSelection = addictionSelection
                state.userSleepSelection = sleepSelection
                state.userWithoutPhoneSelection = withoutPhoneSelection
                state.userIdleCheckSelection = idleCheckSelection
                state.userAgeSelection = ageSelection
                return .none

            case .resultsLoading(.delegate(.resultsCalculated)):
                state.showResultsLoading = false
                state.showResults = true
                return .none

            case .results(.delegate(.showAddictionScore)):
                state.showResults = false
                state.showAddictionScore = true
                
                // Calculate user data and send to addiction score
                guard let hourSelection = state.userHourSelection,
                      let addictionSelection = state.userAddictionSelection,
                      let sleepSelection = state.userSleepSelection,
                      let withoutPhoneSelection = state.userWithoutPhoneSelection,
                      let idleCheckSelection = state.userIdleCheckSelection,
                      let ageSelection = state.userAgeSelection else {
                    return .none
                }
                
                let userData = UserPhoneData(
                    dailyHours: hourSelection.dailyHours,
                    addictionLevel: addictionSelection,
                    sleepImpact: sleepSelection,
                    withoutPhoneAnxiety: withoutPhoneSelection,
                    idleCheckFrequency: idleCheckSelection,
                    ageGroup: ageSelection
                )
                
                return .send(.addictionScore(.calculateScore(userData)))

            case .addictionScore(.delegate(.showNextScreen)):
                state.showAddictionScore = false
                // TODO: Navigate to next screen (solutions/recommendations)
                return .none
                
            case .onboarding:
                return .none
                
            case .resultsLoading:
                return .none
                
            case .results:
                return .none
                
            case .addictionScore:
                return .none
            }
        }
        
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        
        Scope(state: \.resultsLoading, action: \.resultsLoading) {
            ResultsLoadingFeature()
        }
        
        Scope(state: \.results, action: \.results) {
            ResultsFeature()
        }
        
        Scope(state: \.addictionScore, action: \.addictionScore) {
            AddictionScoreFeature()
        }
    }
}
 
