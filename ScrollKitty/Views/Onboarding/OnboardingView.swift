import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {
    @Bindable var store: StoreOf<OnboardingFeature>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            EmptyView()
        } destination: { store in
            switch store.case {
            case let .splash(store):
                SplashView(store: store)
                    .navigationBarBackButtonHidden(true)
                    .toolbarRole(.editor)
                
            case let .welcome(store):
                WelcomeView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)
            case let .usageQuestion(store):
                UsageQuestionView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)
            case let .addiction(store):
                AddictionView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)
            case let .sleep(store):
                SleepView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)
            case let .withoutPhone(store):
                WithoutPhoneView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)
            case let .idleCheck(store):
                IdleCheckView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)
            case let .age(store):
                AgeView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)
            }
        }
        .onAppear {
            store.send(.onAppear)
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
