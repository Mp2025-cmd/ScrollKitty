//
//  ContentView.swift
//  ScrollKitty
//
//  Created by Peter on 10/19/25.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        switch store.destination {
        case .onboarding:
            OnboardingView(
                store: store.scope(state: \.onboarding, action: \.onboarding)
            )
        case .resultsLoading:
            ResultsLoadingView(
                store: store.scope(state: \.resultsLoading, action: \.resultsLoading)
            )
        case .results:
            ResultsView(
                store: store.scope(state: \.results, action: \.results)
            )
        case .addictionScore:
            AddictionScoreView(
                store: store.scope(state: \.addictionScore, action: \.addictionScore)
            )
        case .yearsLost:
            YearsLostView(
                store: store.scope(state: \.yearsLost, action: \.yearsLost)
            )
        case .solutionIntro:
            SolutionIntroView(
                store: store.scope(state: \.solutionIntro, action: \.solutionIntro)
            )
        case .screenTimeAccess:
            ScreenTimeAccessView(
                store: store.scope(state: \.screenTimeAccess, action: \.screenTimeAccess)
            )
        case .appSelection:
            AppSelectionView(
                store: store.scope(state: \.appSelection, action: \.appSelection)
            )
        case .dailyLimit:
            DailyLimitView(
                store: store.scope(state: \.dailyLimit, action: \.dailyLimit)
            )
        case .characterIntro:
            CharacterIntroView(
                store: store.scope(state: \.characterIntro, action: \.characterIntro)
            )
        case .scrollKittyLifecycle:
            ScrollKittyLifecycleView(
                store: store.scope(state: \.scrollKittyLifecycle, action: \.scrollKittyLifecycle)
            )
        case .commitment:
            CommitmentView(
                store: store.scope(state: \.commitment, action: \.commitment)
            )
        case .home:
            HomeView(
                store: store.scope(state: \.home, action: \.home)
            )
        }
    }
}

#Preview {
    ContentView(
        store: Store(
            initialState: AppFeature.State(),
            reducer: { AppFeature() }
        )
    )
}
