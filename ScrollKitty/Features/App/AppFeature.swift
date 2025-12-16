import ComposableArchitecture
import FamilyControls
import Foundation

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        // Persistent onboarding state using TCA's @Shared with App Group UserDefaults
        // This automatically syncs with UserDefaults and persists across app launches
        @Shared(.appStorage("hasCompletedOnboarding", store: UserDefaults.appGroup))
        var hasCompletedOnboarding = false

        // Navigation destination - initialized from persistent state on first launch
        var destination: Destination = UserDefaults.appGroup.bool(forKey: "hasCompletedOnboarding") ? .home : .onboarding

        // Feature States
        var onboarding = OnboardingFeature.State()
        var home = HomeFeature.State()
    }

    enum Destination: Equatable {
        case onboarding
        case home
    }

    enum Action {
        case onboarding(OnboardingFeature.Action)
        case home(HomeFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onboarding(.delegate(.onboardingComplete)):
                state.destination = .home
                // Mark onboarding as complete via @Shared (automatically persists to UserDefaults)
                // Use withLock for thread-safe modification
                state.$hasCompletedOnboarding.withLock { $0 = true }
                return .none

            case .onboarding:
                return .none

            case .home:
                return .none
            }
        }

        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }

        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
    }
}

// MARK: - Swift 6 Sendable Conformance

extension FamilyActivitySelection: @unchecked @retroactive Sendable {}
