import ComposableArchitecture

@Reducer
struct OnboardingFeature {
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()

        // Store selections as user progresses
        var hourSelection: HourOption?
        var addictionSelection: AddictionOption?
        var sleepSelection: SleepOption?
        var withoutPhoneSelection: WithoutPhoneOption?
        var idleCheckSelection: IdleCheckOption?
    }
    enum Action: Equatable {
        case onAppear
        case path(StackAction<Path.State, Path.Action>)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case onboardingCompleted(
                hourSelection: HourOption,
                addictionSelection: AddictionOption,
                sleepSelection: SleepOption,
                withoutPhoneSelection: WithoutPhoneOption,
                idleCheckSelection: IdleCheckOption,
                ageSelection: AgeOption
            )
            case goBack
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
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.path.append(.splash(SplashFeature.State()))
                return .none
                
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
                // All selections collected, send completion
                guard let hourSelection = state.hourSelection,
                      let addictionSelection = state.addictionSelection,
                      let sleepSelection = state.sleepSelection,
                      let withoutPhoneSelection = state.withoutPhoneSelection,
                      let idleCheckSelection = state.idleCheckSelection else {
                    return .none
                }

                return .send(.delegate(.onboardingCompleted(
                    hourSelection: hourSelection,
                    addictionSelection: addictionSelection,
                    sleepSelection: sleepSelection,
                    withoutPhoneSelection: withoutPhoneSelection,
                    idleCheckSelection: idleCheckSelection,
                    ageSelection: ageSelection
                )))
                
            case .path(.element(id: _, action: .usageQuestion(.delegate(.goBack)))),
                 .path(.element(id: _, action: .addiction(.delegate(.goBack)))),
                 .path(.element(id: _, action: .sleep(.delegate(.goBack)))),
                 .path(.element(id: _, action: .withoutPhone(.delegate(.goBack)))),
                 .path(.element(id: _, action: .idleCheck(.delegate(.goBack)))),
                 .path(.element(id: _, action: .age(.delegate(.goBack)))):
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
