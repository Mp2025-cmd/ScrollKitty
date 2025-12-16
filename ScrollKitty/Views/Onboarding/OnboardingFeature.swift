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
        //case focusWindow(FocusWindowFeature)
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
                // Only initialize if path is empty to prevent reset on view re-render
                guard state.path.isEmpty else { return .none }
                state.path.append(.splash(SplashFeature.State()))
                return .none

            // MARK: - Initial Survey Flow (Splash → Age)

            case let .path(.element(id: id, action: .splash(.delegate(.splashCompleted)))):
                guard id == state.path.ids.last else { return .none }
                state.path.append(.welcome(WelcomeFeature.State()))
                return .none

            case let .path(.element(id: id, action: .welcome(.delegate(.proceedToNextStep)))):
                guard id == state.path.ids.last else { return .none }
                state.path.append(.usageQuestion(UsageQuestionFeature.State()))
                return .none

            case .path(.element(id: let id, action: .usageQuestion(.delegate(.completeWithSelection(let selection))))):
                guard id == state.path.ids.last else { return .none }
                state.hourSelection = selection
                state.path.append(.addiction(AddictionFeature.State()))
                return .none

            case .path(.element(id: let id, action: .addiction(.delegate(.completeWithSelection(let selection))))):
                guard id == state.path.ids.last else { return .none }
                state.addictionSelection = selection
                state.path.append(.sleep(SleepFeature.State()))
                return .none

            case .path(.element(id: let id, action: .sleep(.delegate(.completeWithSelection(let selection))))):
                guard id == state.path.ids.last else { return .none }
                state.sleepSelection = selection
                state.path.append(.withoutPhone(WithoutPhoneFeature.State()))
                return .none

            case .path(.element(id: let id, action: .withoutPhone(.delegate(.completeWithSelection(let selection))))):
                guard id == state.path.ids.last else { return .none }
                state.withoutPhoneSelection = selection
                state.path.append(.idleCheck(IdleCheckFeature.State()))
                return .none

            case .path(.element(id: let id, action: .idleCheck(.delegate(.completeWithSelection(let selection))))):
                guard id == state.path.ids.last else { return .none }
                state.idleCheckSelection = selection
                state.path.append(.age(AgeFeature.State()))
                return .none

            case .path(.element(id: let id, action: .age(.delegate(.completeWithSelection(let ageSelection))))):
                guard id == state.path.ids.last else { return .none }
                state.ageSelection = ageSelection
                state.path.append(.resultsLoading(ResultsLoadingFeature.State()))
                return .none

            // MARK: - Results Flow (ResultsLoading → YearsLost)

            case let .path(.element(id: id, action: .resultsLoading(.delegate(.resultsCalculated)))):
                guard id == state.path.ids.last else { return .none }
                state.path.append(.results(ResultsFeature.State()))
                return .none

            case let .path(.element(id: id, action: .results(.delegate(.showAddictionScore)))):
                guard id == state.path.ids.last else { return .none }
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

            case let .path(.element(id: id, action: .addictionScore(.delegate(.showNextScreen)))):
                guard id == state.path.ids.last else { return .none }
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

            case let .path(.element(id: id, action: .yearsLost(.delegate(.showNextScreen)))):
                guard id == state.path.ids.last else { return .none }
                state.path.append(.solutionIntro(SolutionIntroFeature.State()))
                return .none

            // MARK: - Solution Flow (SolutionIntro → Commitment)

            case let .path(.element(id: id, action: .solutionIntro(.delegate(.showNextScreen)))):
                guard id == state.path.ids.last else { return .none }
                state.path.append(.screenTimeAccess(ScreenTimeAccessFeature.State()))
                return .none

            case let .path(.element(id: id, action: .screenTimeAccess(.delegate(.showNextScreen)))):
                guard id == state.path.ids.last else { return .none }
                state.path.append(.appSelection(AppSelectionFeature.State()))
                return .none

            case .path(.element(id: let id, action: .appSelection(.delegate(.completeWithSelection(let selection))))):
                guard id == state.path.ids.last else { return .none }
                state.selectedApps = selection
                state.path.append(.dailyLimit(DailyLimitFeature.State()))
                // Save apps, initialize health to 100, apply shields, start monitoring
                return .run { [screenTimeManager, userSettings] _ in
                    await userSettings.saveSelectedApps(selection)

                    // Initialize cat health to 100 (single init point)
                    await userSettings.initializeHealth()

                    await screenTimeManager.applyShields()
                    do {
                        try await screenTimeManager.startMonitoring()
                    } catch {
                    }
                }

            case .path(.element(id: let id, action: .dailyLimit(.delegate(.completeWithSelection(let selection))))):
                guard id == state.path.ids.last else { return .none }
                state.selectedLimit = selection
                state.path.append(.shieldFrequency(ShieldFrequencyFeature.State()))
                // Daily limit is for narrative/timeline only - no game logic effect
                return .run { [userSettings] _ in
                    await userSettings.saveDailyLimit(selection.minutes)
                }

            case .path(.element(id: let id, action: .shieldFrequency(.delegate(.completeWithSelection(let selection))))):
                guard id == state.path.ids.last else { return .none }
                state.selectedInterval = selection
                // Skip FocusWindow for now - go directly to CharacterIntro
                // state.path.append(.focusWindow(FocusWindowFeature.State()))
                state.path.append(.characterIntro(CharacterIntroFeature.State()))
                return .run { [userSettings] _ in
                    await userSettings.saveShieldInterval(selection.minutes)
                }

            // FocusWindow skipped - commented out
            // case .path(.element(id: let id, action: .focusWindow(.delegate(.completeWithSelection(let data))))):
            //     guard id == state.path.ids.last else { return .none }
            //     state.selectedFocusWindow = data
            //     state.path.append(.characterIntro(CharacterIntroFeature.State()))
            //     return .run { [userSettings] _ in
            //         await userSettings.saveFocusWindow(data)
            //     }

            case let .path(.element(id: id, action: .characterIntro(.delegate(.showNextScreen)))):
                guard id == state.path.ids.last else { return .none }
                state.path.append(.scrollKittyLifecycle(ScrollKittyLifecycleFeature.State()))
                return .none

            case let .path(.element(id: id, action: .scrollKittyLifecycle(.delegate(.showNextScreen)))):
                guard id == state.path.ids.last else { return .none }
                state.path.append(.commitment(CommitmentFeature.State()))
                return .none

            case let .path(.element(id: id, action: .commitment(.delegate(.showNextScreen)))):
                guard id == state.path.ids.last else { return .none }
                // Final screen - save profile, apply shields, start monitoring, then complete onboarding
                return .run { [screenTimeManager, userSettings, state] send in
                    // Save onboarding profile for AI tone tuning
                    if let hourSelection = state.hourSelection,
                       let sleepSelection = state.sleepSelection,
                       let idleCheckSelection = state.idleCheckSelection,
                       let ageSelection = state.ageSelection {

                        let profile = UserOnboardingProfile(
                            dailyUsageHours: hourSelection.dailyHours,
                            sleepImpact: sleepSelection.profileValue,
                            ageGroup: ageSelection.profileValue,
                            idleCheckFrequency: idleCheckSelection.profileValue
                        )
                        await userSettings.saveOnboardingProfile(profile)
                    }

                    let defaults = UserDefaults.appGroup

                    if defaults.data(forKey: "selectedApps") != nil {
                        await screenTimeManager.applyShields()
                        do {
                            try await screenTimeManager.startMonitoring()
                        } catch {
                        }
                    }

                    await send(.delegate(.onboardingComplete))
                }

            // MARK: - Back Navigation

            case .path(.element(id: let id, action: .usageQuestion(.delegate(.goBack)))),
                 .path(.element(id: let id, action: .addiction(.delegate(.goBack)))),
                 .path(.element(id: let id, action: .sleep(.delegate(.goBack)))),
                 .path(.element(id: let id, action: .withoutPhone(.delegate(.goBack)))),
                 .path(.element(id: let id, action: .idleCheck(.delegate(.goBack)))),
                 .path(.element(id: let id, action: .age(.delegate(.goBack)))),
                 .path(.element(id: let id, action: .addictionScore(.delegate(.goBack)))),
                 .path(.element(id: let id, action: .yearsLost(.delegate(.goBack)))),
                 .path(.element(id: let id, action: .solutionIntro(.delegate(.goBack)))),
                 .path(.element(id: let id, action: .screenTimeAccess(.delegate(.goBack)))),
                 .path(.element(id: let id, action: .appSelection(.delegate(.goBack)))),
                 .path(.element(id: let id, action: .dailyLimit(.delegate(.goBack)))),
                 .path(.element(id: let id, action: .shieldFrequency(.delegate(.goBack)))),
                 // FocusWindow skipped - commented out
                 // .path(.element(id: let id, action: .focusWindow(.delegate(.goBack)))),
                 .path(.element(id: let id, action: .characterIntro(.delegate(.goBack)))),
                 .path(.element(id: let id, action: .scrollKittyLifecycle(.delegate(.goBack)))),
                 .path(.element(id: let id, action: .commitment(.delegate(.goBack)))):
                guard id == state.path.ids.last else { return .none }
                state.path.removeLast()
                return .none

            case .path:
                return .none

            case .delegate:
                return .none
            }
        }
        ._printChanges()
        .forEach(\.path, action: \.path)
    }
}
