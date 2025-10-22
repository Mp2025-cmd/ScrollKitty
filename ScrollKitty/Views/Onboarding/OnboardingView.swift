import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {
    let store: StoreOf<OnboardingFeature>
    
    var body: some View {
        NavigationStackStore(
            self.store.scope(state: \.path, action: \.path)
        ) {
            SplashView(store: self.store.scope(state: \.splash, action: \.splash))
        } destination: { store in
            switch store.case {
            case let .welcome(store):
                WelcomeView(store: store)

            case let .usageQuestion(store):
                UsageQuestionView(store: store)

            case let .addiction(store):
                AddictionView(store: store)

            case let .sleep(store):
                SleepView(store: store)

            case let .withoutPhone(store):
                WithoutPhoneView(store: store)

            case let .idleCheck(store):
                IdleCheckView(store: store)

            case let .age(store):
                AgeView(store: store)
            }
        }
    }
}

#Preview {
    OnboardingView(
        store: Store(
            initialState: OnboardingFeature.State(),
            reducer: { OnboardingFeature() }
        )
    )
}
