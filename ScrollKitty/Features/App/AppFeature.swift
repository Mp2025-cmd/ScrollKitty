import ComposableArchitecture
import FamilyControls

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var onboarding = OnboardingFeature.State()
        var resultsLoading = ResultsLoadingFeature.State()
        var results = ResultsFeature.State()
        var addictionScore = AddictionScoreFeature.State()
        var yearsLost = YearsLostFeature.State()
        var appSelection = AppSelectionFeature.State()
        var dailyLimit = DailyLimitFeature.State()
        var solutionIntro = SolutionIntroFeature.State()
        var screenTimeAccess = ScreenTimeAccessFeature.State()
        var characterIntro = CharacterIntroFeature.State()
        var scrollKittyLifecycle = ScrollKittyLifecycleFeature.State()
        var commitment = CommitmentFeature.State()
        var home = HomeFeature.State()
        var isOnboardingComplete = false
        var showResultsLoading = false
        var showResults = false
        var showAddictionScore = false
        var showYearsLost = false
        var showAppSelection = false
        var showDailyLimit = false
        var showSolutionIntro = false
        var showScreenTimeAccess = false
        var showCharacterIntro = false
        var showScrollKittyLifecycle = false
        var showCommitment = false
        var showHome = false
        var userHourSelection: HourOption?
        var userAddictionSelection: AddictionOption?
        var userSleepSelection: SleepOption?
        var userWithoutPhoneSelection: WithoutPhoneOption?
        var userIdleCheckSelection: IdleCheckOption?
        var userAgeSelection: AgeOption?
        var selectedApps: FamilyActivitySelection?
        var selectedLimit: DailyLimitOption?
    }

    enum Action {
        case onboarding(OnboardingFeature.Action)
        case resultsLoading(ResultsLoadingFeature.Action)
        case results(ResultsFeature.Action)
        case addictionScore(AddictionScoreFeature.Action)
        case yearsLost(YearsLostFeature.Action)
        case appSelection(AppSelectionFeature.Action)
        case dailyLimit(DailyLimitFeature.Action)
        case solutionIntro(SolutionIntroFeature.Action)
        case screenTimeAccess(ScreenTimeAccessFeature.Action)
        case characterIntro(CharacterIntroFeature.Action)
        case scrollKittyLifecycle(ScrollKittyLifecycleFeature.Action)
        case commitment(CommitmentFeature.Action)
        case home(HomeFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onboarding(.delegate(.goBack)):
                // Handle back navigation within onboarding flow
                return .none
                
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

            case .addictionScore(.delegate(.goBack)):
                state.showAddictionScore = false
                state.showResults = true
                return .none
                
            case .addictionScore(.delegate(.showNextScreen)):
                state.showAddictionScore = false
                state.showYearsLost = true

                // Pass userData and userScore to Years Lost screen
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

                let userScore = state.addictionScore.userScore

                return .send(.yearsLost(.calculateYearsLost(userData, userScore: userScore)))
                
            case .yearsLost(.delegate(.goBack)):
                state.showYearsLost = false
                state.showAddictionScore = true
                return .none
                
            case .solutionIntro(.delegate(.goBack)):
                state.showSolutionIntro = false
                state.showDailyLimit = true
                return .none
                
            case .screenTimeAccess(.delegate(.goBack)):
                state.showScreenTimeAccess = false
                state.showSolutionIntro = true
                return .none
                
            case .characterIntro(.delegate(.goBack)):
                state.showCharacterIntro = false
                state.showScreenTimeAccess = true
                return .none
                
            case .yearsLost(.delegate(.showNextScreen)):
                state.showYearsLost = false
                state.showAppSelection = true
                return .none
                
            case .appSelection(.delegate(.completeWithSelection(let selection))):
                state.selectedApps = selection
                state.showAppSelection = false
                state.showDailyLimit = true
                return .none
                
            case .dailyLimit(.delegate(.completeWithSelection(let selection))):
                state.selectedLimit = selection
                state.showDailyLimit = false
                state.showSolutionIntro = true
                return .none
                
            case .appSelection(.delegate(.goBack)):
                state.showAppSelection = false
                state.showYearsLost = true
                return .none
                
            case .dailyLimit(.delegate(.goBack)):
                state.showDailyLimit = false
                state.showAppSelection = true
                return .none
                
            case .solutionIntro(.delegate(.showNextScreen)):
                state.showSolutionIntro = false
                state.showScreenTimeAccess = true
                return .none
                
            case .screenTimeAccess(.delegate(.showNextScreen)):
                state.showScreenTimeAccess = false
                state.showCharacterIntro = true
                return .none
                
            case .characterIntro(.delegate(.showNextScreen)):
                state.showCharacterIntro = false
                state.showScrollKittyLifecycle = true
                return .none
                
            case .scrollKittyLifecycle(.delegate(.goBack)):
                state.showScrollKittyLifecycle = false
                state.showCharacterIntro = true
                return .none
                
            case .scrollKittyLifecycle(.delegate(.showNextScreen)):
                state.showScrollKittyLifecycle = false
                state.showCommitment = true
                return .none
                
            case .commitment(.delegate(.goBack)):
                state.showCommitment = false
                state.showScrollKittyLifecycle = true
                return .none
                
            case .commitment(.delegate(.showNextScreen)):
                state.showCommitment = false
                state.showHome = true
                return .none
                
            case .onboarding:
                return .none
                
            case .resultsLoading:
                return .none
                
            case .results:
                return .none
                
            case .addictionScore:
                return .none
                
            case .yearsLost:
                return .none
                
            case .appSelection:
                return .none
                
            case .dailyLimit:
                return .none
                
            case .solutionIntro:
                return .none
                
            case .screenTimeAccess:
                return .none
                
            case .characterIntro:
                return .none
                
            case .scrollKittyLifecycle:
                return .none
            
            case .commitment:
                return .none
                
            case .home:
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
        
        Scope(state: \.yearsLost, action: \.yearsLost) {
            YearsLostFeature()
        }
        
        Scope(state: \.appSelection, action: \.appSelection) {
            AppSelectionFeature()
        }
        
        Scope(state: \.dailyLimit, action: \.dailyLimit) {
            DailyLimitFeature()
        }
        
        Scope(state: \.solutionIntro, action: \.solutionIntro) {
            SolutionIntroFeature()
        }
        
        Scope(state: \.screenTimeAccess, action: \.screenTimeAccess) {
            ScreenTimeAccessFeature()
        }
        
        Scope(state: \.characterIntro, action: \.characterIntro) {
            CharacterIntroFeature()
        }
        
        Scope(state: \.scrollKittyLifecycle, action: \.scrollKittyLifecycle) {
            ScrollKittyLifecycleFeature()
        }
        
        Scope(state: \.commitment, action: \.commitment) {
            CommitmentFeature()
        }
        
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
    }
}
 
