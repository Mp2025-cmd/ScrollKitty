import ComposableArchitecture
import FamilyControls
import Foundation

@Reducer
struct OnboardingFeature {
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()

        // Store selections as user progresses (initial survey)
        var hourSelection: HourOption?
        var addictionSelection: AddictionOption?
        var sleepSelection: SleepOption?
        var withoutPhoneSelection: WithoutPhoneOption?
        var idleCheckSelection: IdleCheckOption?
        var ageSelection: AgeOption?

        // Store selections from later screens
        var selectedApps: FamilyActivitySelection?
        var selectedLimit: DailyLimitOption?
        var selectedInterval: ShieldIntervalOption?
        var selectedFocusWindow: FocusWindowData?
    }

    enum Action: Equatable {
        case onAppear
        case path(StackAction<Path.State, Path.Action>)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case onboardingComplete
        }
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Path {
        case splash(SplashFeature)
        case welcome(WelcomeFeature)
        case usageQuestion(UsageQuestionFeature)
        case addiction(AddictionFeature)
        case sleep(SleepFeature)
        case withoutPhone(WithoutPhoneFeature)
        case idleCheck(IdleCheckFeature)
        case age(AgeFeature)
        case resultsLoading(ResultsLoadingFeature)
        case results(ResultsFeature)
        case addictionScore(AddictionScoreFeature)
        case yearsLost(YearsLostFeature)
        case solutionIntro(SolutionIntroFeature)
        case screenTimeAccess(ScreenTimeAccessFeature)
        case appSelection(AppSelectionFeature)
        case dailyLimit(DailyLimitFeature)
        case shieldFrequency(ShieldFrequencyFeature)
        case focusWindow(FocusWindowFeature)
        case characterIntro(CharacterIntroFeature)
        case scrollKittyLifecycle(ScrollKittyLifecycleFeature)
        case commitment(CommitmentFeature)
    }

    @Dependency(\.userSettings) var userSettings
    @Dependency(\.screenTimeManager) var screenTimeManager

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.path.append(.splash(SplashFeature.State()))
                return .none

            // MARK: - Initial Survey Flow (Splash → Age)

            case .path(.element(id: _, action: .splash(.delegate(.splashCompleted)))):
                state.path.append(.welcome(WelcomeFeature.State()))
                return .none

            case .path(.element(id: _, action: .welcome(.delegate(.proceedToNextStep)))):
                state.path.append(.usageQuestion(UsageQuestionFeature.State()))
                return .none

            case .path(.element(id: _, action: .usageQuestion(.delegate(.completeWithSelection(let selection))))):
                state.hourSelection = selection
                state.path.append(.addiction(AddictionFeature.State()))
                return .none

            case .path(.element(id: _, action: .addiction(.delegate(.completeWithSelection(let selection))))):
                state.addictionSelection = selection
                state.path.append(.sleep(SleepFeature.State()))
                return .none

            case .path(.element(id: _, action: .sleep(.delegate(.completeWithSelection(let selection))))):
                state.sleepSelection = selection
                state.path.append(.withoutPhone(WithoutPhoneFeature.State()))
                return .none

            case .path(.element(id: _, action: .withoutPhone(.delegate(.completeWithSelection(let selection))))):
                state.withoutPhoneSelection = selection
                state.path.append(.idleCheck(IdleCheckFeature.State()))
                return .none

            case .path(.element(id: _, action: .idleCheck(.delegate(.completeWithSelection(let selection))))):
                state.idleCheckSelection = selection
                state.path.append(.age(AgeFeature.State()))
                return .none

            case .path(.element(id: _, action: .age(.delegate(.completeWithSelection(let ageSelection))))):
                state.ageSelection = ageSelection
                state.path.append(.resultsLoading(ResultsLoadingFeature.State()))
                return .none

            // MARK: - Results Flow (ResultsLoading → YearsLost)

            case .path(.element(id: _, action: .resultsLoading(.delegate(.resultsCalculated)))):
                state.path.append(.results(ResultsFeature.State()))
                return .none

            case .path(.element(id: _, action: .results(.delegate(.showAddictionScore)))):
                guard let hourSelection = state.hourSelection,
                      let addictionSelection = state.addictionSelection,
                      let sleepSelection = state.sleepSelection,
                      let withoutPhoneSelection = state.withoutPhoneSelection,
                      let idleCheckSelection = state.idleCheckSelection,
                      let ageSelection = state.ageSelection else {
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

                state.path.append(.addictionScore(AddictionScoreFeature.State()))
                return .send(.path(.element(id: state.path.ids.last!, action: .addictionScore(.calculateScore(userData)))))

            case .path(.element(id: _, action: .addictionScore(.delegate(.showNextScreen)))):
                guard let hourSelection = state.hourSelection,
                      let addictionSelection = state.addictionSelection,
                      let sleepSelection = state.sleepSelection,
                      let withoutPhoneSelection = state.withoutPhoneSelection,
                      let idleCheckSelection = state.idleCheckSelection,
                      let ageSelection = state.ageSelection else {
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

                // Get userScore from the AddictionScore state in the path
                var userScore: Double = 0
                for element in state.path {
                    if case let .addictionScore(addictionState) = element {
                        userScore = addictionState.userScore
                        break
                    }
                }

                state.path.append(.yearsLost(YearsLostFeature.State()))
                return .send(.path(.element(id: state.path.ids.last!, action: .yearsLost(.calculateYearsLost(userData, userScore: userScore)))))

            case .path(.element(id: _, action: .yearsLost(.delegate(.showNextScreen)))):
                state.path.append(.solutionIntro(SolutionIntroFeature.State()))
                return .none

            // MARK: - Solution Flow (SolutionIntro → Commitment)

            case .path(.element(id: _, action: .solutionIntro(.delegate(.showNextScreen)))):
                state.path.append(.screenTimeAccess(ScreenTimeAccessFeature.State()))
                return .none

            case .path(.element(id: _, action: .screenTimeAccess(.delegate(.showNextScreen)))):
                state.path.append(.appSelection(AppSelectionFeature.State()))
                return .none

            case .path(.element(id: _, action: .appSelection(.delegate(.completeWithSelection(let selection))))):
                state.selectedApps = selection
                state.path.append(.dailyLimit(DailyLimitFeature.State()))
                // Save apps, initialize health to 100, apply shields, start monitoring
                return .run { [screenTimeManager, userSettings] _ in
                    await userSettings.saveSelectedApps(selection)

                    // Initialize cat health to 100 (single init point)
                    await userSettings.initializeHealth()
                    print("[OnboardingFeature] 💚 Health initialized to 100")

                    print("[OnboardingFeature] Apps saved - applying shields immediately...")
                    await screenTimeManager.applyShields()
                    do {
                        try await screenTimeManager.startMonitoring()
                        print("[OnboardingFeature] ✅ Monitoring started (for re-shield only)")
                    } catch {
                        print("[OnboardingFeature] ⚠️ Monitoring setup failed: \(error)")
                    }
                }

            case .path(.element(id: _, action: .dailyLimit(.delegate(.completeWithSelection(let selection))))):
                state.selectedLimit = selection
                state.path.append(.shieldFrequency(ShieldFrequencyFeature.State()))
                // Daily limit is for narrative/timeline only - no game logic effect
                return .run { [userSettings] _ in
                    await userSettings.saveDailyLimit(selection.minutes)
                }

            case .path(.element(id: _, action: .shieldFrequency(.delegate(.completeWithSelection(let selection))))):
                state.selectedInterval = selection
                state.path.append(.focusWindow(FocusWindowFeature.State()))
                return .run { [userSettings] _ in
                    await userSettings.saveShieldInterval(selection.minutes)
                }

            case .path(.element(id: _, action: .focusWindow(.delegate(.completeWithSelection(let data))))):
                state.selectedFocusWindow = data
                state.path.append(.characterIntro(CharacterIntroFeature.State()))
                return .run { [userSettings] _ in
                    await userSettings.saveFocusWindow(data)
                }

            case .path(.element(id: _, action: .characterIntro(.delegate(.showNextScreen)))):
                state.path.append(.scrollKittyLifecycle(ScrollKittyLifecycleFeature.State()))
                return .none

            case .path(.element(id: _, action: .scrollKittyLifecycle(.delegate(.showNextScreen)))):
                state.path.append(.commitment(CommitmentFeature.State()))
                return .none

            case .path(.element(id: _, action: .commitment(.delegate(.showNextScreen)))):
                // Final screen - apply shields, start monitoring, then complete onboarding
                return .run { [screenTimeManager] send in
                    let defaults = UserDefaults.appGroup

                    if defaults.data(forKey: "selectedApps") != nil {
                        print("[OnboardingFeature] Apps selected - applying shields...")
                        await screenTimeManager.applyShields()
                        do {
                            try await screenTimeManager.startMonitoring()
                            print("[OnboardingFeature] ✅ Monitoring started successfully")
                        } catch {
                            print("[OnboardingFeature] ❌ Monitoring failed: \(error)")
                        }
                    } else {
                        print("[OnboardingFeature] ⚠️ No apps selected - monitoring will start after app selection")
                    }

                    await send(.delegate(.onboardingComplete))
                }

            // MARK: - Back Navigation

            case .path(.element(id: _, action: .usageQuestion(.delegate(.goBack)))),
                 .path(.element(id: _, action: .addiction(.delegate(.goBack)))),
                 .path(.element(id: _, action: .sleep(.delegate(.goBack)))),
                 .path(.element(id: _, action: .withoutPhone(.delegate(.goBack)))),
                 .path(.element(id: _, action: .idleCheck(.delegate(.goBack)))),
                 .path(.element(id: _, action: .age(.delegate(.goBack)))),
                 .path(.element(id: _, action: .addictionScore(.delegate(.goBack)))),
                 .path(.element(id: _, action: .yearsLost(.delegate(.goBack)))),
                 .path(.element(id: _, action: .solutionIntro(.delegate(.goBack)))),
                 .path(.element(id: _, action: .screenTimeAccess(.delegate(.goBack)))),
                 .path(.element(id: _, action: .appSelection(.delegate(.goBack)))),
                 .path(.element(id: _, action: .dailyLimit(.delegate(.goBack)))),
                 .path(.element(id: _, action: .shieldFrequency(.delegate(.goBack)))),
                 .path(.element(id: _, action: .focusWindow(.delegate(.goBack)))),
                 .path(.element(id: _, action: .characterIntro(.delegate(.goBack)))),
                 .path(.element(id: _, action: .scrollKittyLifecycle(.delegate(.goBack)))),
                 .path(.element(id: _, action: .commitment(.delegate(.goBack)))):
                state.path.removeLast()
                return .none

            case .path:
                return .none

            case .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
