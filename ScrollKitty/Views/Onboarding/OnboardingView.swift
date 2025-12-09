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

            case let .resultsLoading(store):
                ResultsLoadingView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)

            case let .results(store):
                ResultsView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)

            case let .addictionScore(store):
                AddictionScoreView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)

            case let .yearsLost(store):
                YearsLostView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)

            case let .solutionIntro(store):
                SolutionIntroView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)

            case let .screenTimeAccess(store):
                ScreenTimeAccessView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)

            case let .appSelection(store):
                AppSelectionView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)

            case let .dailyLimit(store):
                DailyLimitView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)

            case let .shieldFrequency(store):
                ShieldFrequencyView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)

            // FocusWindow skipped - commented out
            // case let .focusWindow(store):
            //     FocusWindowView(store: store)
            //         .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)

            case let .characterIntro(store):
                CharacterIntroView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)

            case let .scrollKittyLifecycle(store):
                ScrollKittyLifecycleView(store: store)
                    .toolbarRole(.editor)
                    .navigationBarBackButtonHidden(true)

            case let .commitment(store):
                CommitmentView(store: store)
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
