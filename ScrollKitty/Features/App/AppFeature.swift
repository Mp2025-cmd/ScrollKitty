import ComposableArchitecture
import FamilyControls
import Foundation

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        // Navigation
        var destination: Destination = .onboarding
        
        // Feature States
        var onboarding = OnboardingFeature.State()
        var resultsLoading = ResultsLoadingFeature.State()
        var results = ResultsFeature.State()
        var addictionScore = AddictionScoreFeature.State()
        var yearsLost = YearsLostFeature.State()
        var appSelection = AppSelectionFeature.State()
        var dailyLimit = DailyLimitFeature.State()
        var shieldFrequency = ShieldFrequencyFeature.State()
        var focusWindow = FocusWindowFeature.State()
        var solutionIntro = SolutionIntroFeature.State()
        var screenTimeAccess = ScreenTimeAccessFeature.State()
        var characterIntro = CharacterIntroFeature.State()
        var scrollKittyLifecycle = ScrollKittyLifecycleFeature.State()
        var commitment = CommitmentFeature.State()
        var home = HomeFeature.State()
        
        // User Selections
        var userHourSelection: HourOption?
        var userAddictionSelection: AddictionOption?
        var userSleepSelection: SleepOption?
        var userWithoutPhoneSelection: WithoutPhoneOption?
        var userIdleCheckSelection: IdleCheckOption?
        var userAgeSelection: AgeOption?
        var selectedApps: FamilyActivitySelection?
        var selectedLimit: DailyLimitOption?
        var selectedInterval: ShieldIntervalOption?
    }
    
    enum Destination: Equatable {
        case onboarding
        case resultsLoading
        case results
        case addictionScore
        case yearsLost
        case solutionIntro
        case screenTimeAccess
        case appSelection
        case dailyLimit
        case shieldFrequency
        case focusWindow
        case characterIntro
        case scrollKittyLifecycle
        case commitment
        case home
    }
    
    enum Action {
        case onboarding(OnboardingFeature.Action)
        case resultsLoading(ResultsLoadingFeature.Action)
        case results(ResultsFeature.Action)
        case addictionScore(AddictionScoreFeature.Action)
        case yearsLost(YearsLostFeature.Action)
        case appSelection(AppSelectionFeature.Action)
        case dailyLimit(DailyLimitFeature.Action)
        case shieldFrequency(ShieldFrequencyFeature.Action)
        case focusWindow(FocusWindowFeature.Action)
        case solutionIntro(SolutionIntroFeature.Action)
        case screenTimeAccess(ScreenTimeAccessFeature.Action)
        case characterIntro(CharacterIntroFeature.Action)
        case scrollKittyLifecycle(ScrollKittyLifecycleFeature.Action)
        case commitment(CommitmentFeature.Action)
        case home(HomeFeature.Action)
    }
    
    @Dependency(\.userSettings) var userSettings
    @Dependency(\.screenTimeManager) var screenTimeManager

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
                state.destination = .resultsLoading
                state.userHourSelection = hourSelection
                state.userAddictionSelection = addictionSelection
                state.userSleepSelection = sleepSelection
                state.userWithoutPhoneSelection = withoutPhoneSelection
                state.userIdleCheckSelection = idleCheckSelection
                state.userAgeSelection = ageSelection
                return .none

            case .resultsLoading(.delegate(.resultsCalculated)):
                state.destination = .results
                return .none

            case .results(.delegate(.showAddictionScore)):
                state.destination = .addictionScore
                
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
                state.destination = .results
                return .none
                
            case .addictionScore(.delegate(.showNextScreen)):
                state.destination = .yearsLost

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
                state.destination = .addictionScore
                return .none
                
            case .yearsLost(.delegate(.showNextScreen)):
                state.destination = .solutionIntro
                return .none
                
            case .solutionIntro(.delegate(.showNextScreen)):
                state.destination = .screenTimeAccess
                return .none
                
            case .solutionIntro(.delegate(.goBack)):
                state.destination = .yearsLost
                return .none
                
            case .screenTimeAccess(.delegate(.showNextScreen)):
                state.destination = .appSelection
                return .none
                
            case .screenTimeAccess(.delegate(.goBack)):
                state.destination = .solutionIntro
                return .none
                
            case .appSelection(.delegate(.completeWithSelection(let selection))):
                state.selectedApps = selection
                state.destination = .dailyLimit
                // Save apps and start monitoring
                return .run { [screenTimeManager = self.screenTimeManager] _ in
                    await userSettings.saveSelectedApps(selection)
                    print("[AppFeature] Apps saved - starting monitoring...")
                    do {
                        try await screenTimeManager.startMonitoring()
                        print("[AppFeature] ✅ Monitoring started after app selection")
                    } catch {
                        print("[AppFeature] ⚠️ Monitoring setup failed: \(error)")
                    }
                }
                
            case .appSelection(.delegate(.goBack)):
                state.destination = .screenTimeAccess
                return .none
                
            case .dailyLimit(.delegate(.completeWithSelection(let selection))):
                state.selectedLimit = selection
                state.destination = .shieldFrequency
                return .run { _ in
                    await userSettings.saveDailyLimit(selection.minutes)
                    await userSettings.saveHealthCost(selection.healthCost)
                }
                
            case .dailyLimit(.delegate(.goBack)):
                state.destination = .appSelection
                return .none

            case .shieldFrequency(.delegate(.completeWithSelection(let selection))):
                state.selectedInterval = selection
                state.destination = .focusWindow
                return .run { _ in
                    await userSettings.saveShieldInterval(selection.minutes)
                }

            case .shieldFrequency(.delegate(.goBack)):
                state.destination = .dailyLimit
                return .none
                
            case .focusWindow(.delegate(.completeWithSelection(let data))):
                state.destination = .characterIntro
                return .run { _ in
                    await userSettings.saveFocusWindow(data)
                }
                
            case .focusWindow(.delegate(.goBack)):
                state.destination = .shieldFrequency
                return .none
                
            case .characterIntro(.delegate(.showNextScreen)):
                state.destination = .scrollKittyLifecycle
                return .none
                
            case .characterIntro(.delegate(.goBack)):
                state.destination = .focusWindow
                return .none
                
            case .scrollKittyLifecycle(.delegate(.goBack)):
                state.destination = .characterIntro
                return .none
                
            case .scrollKittyLifecycle(.delegate(.showNextScreen)):
                state.destination = .commitment
                return .none
                
            case .commitment(.delegate(.goBack)):
                state.destination = .scrollKittyLifecycle
                return .none
                
            case .commitment(.delegate(.showNextScreen)):
                state.destination = .home
                // Start DeviceActivity monitoring only if apps selected
                return .run { [screenTimeManager = self.screenTimeManager] _ in
                    print("[AppFeature] Checking for app selection before monitoring...")
                    let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
                    if defaults?.data(forKey: "selectedApps") != nil {
                        print("[AppFeature] Apps selected - starting monitoring...")
                        do {
                            try await screenTimeManager.startMonitoring()
                            print("[AppFeature] ✅ Monitoring started successfully")
                        } catch {
                            print("[AppFeature] ❌ Monitoring failed: \(error)")
                        }
                    } else {
                        print("[AppFeature] ⚠️ No apps selected - monitoring will start after app selection")
                    }
                }
                
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

            case .shieldFrequency:
                return .none
                
            case .focusWindow:
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

        Scope(state: \.shieldFrequency, action: \.shieldFrequency) {
            ShieldFrequencyFeature()
        }
        
        Scope(state: \.focusWindow, action: \.focusWindow) {
            FocusWindowFeature()
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

// MARK: - Swift 6 Sendable Conformance

extension FamilyActivitySelection: @unchecked @retroactive Sendable {}

