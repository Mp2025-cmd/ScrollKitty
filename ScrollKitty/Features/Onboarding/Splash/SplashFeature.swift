import ComposableArchitecture

@Reducer
struct SplashFeature {
    @Dependency(\.continuousClock) var clock
    
    @ObservableState
    struct State: Equatable {
        // No state needed - timer is managed by the effect
    }
    
    enum Action: Equatable {
        case onAppear
        case timerTick
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case splashCompleted
        }
    }
    
    nonisolated struct CancelID: Hashable, Sendable {
        static let autoAdvanceTimer = Self()
    }
    
    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .onAppear:
                // Start timer for auto-advance after 2 seconds
                return .run { send in
                    try await clock.sleep(for: .seconds(2))
                    await send(.timerTick)
                }
                .cancellable(id: CancelID.autoAdvanceTimer)
                
            case .timerTick:
                return .send(.delegate(.splashCompleted))
                
            case .delegate:
                return .none
            }
        }
    }
}
