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
        if store.showHome {
            HomeView(
                store: store.scope(state: \.home, action: \.home)
            )
        } else if store.showCommitment {
            CommitmentView(
                store: store.scope(state: \.commitment, action: \.commitment)
            )
        } else if store.showScrollKittyLifecycle {
            ScrollKittyLifecycleView(
                store: store.scope(state: \.scrollKittyLifecycle, action: \.scrollKittyLifecycle)
            )
        } else if store.showCharacterIntro {
            CharacterIntroView(
                store: store.scope(state: \.characterIntro, action: \.characterIntro)
            )
        } else if store.showScreenTimeAccess {
            ScreenTimeAccessView(
                store: store.scope(state: \.screenTimeAccess, action: \.screenTimeAccess)
            )
        } else if store.showSolutionIntro {
            SolutionIntroView(
                store: store.scope(state: \.solutionIntro, action: \.solutionIntro)
            )
        } else if store.showYearsLost {
            YearsLostView(
                store: store.scope(state: \.yearsLost, action: \.yearsLost)
            )
        } else if store.showAddictionScore {
            AddictionScoreView(
                store: store.scope(state: \.addictionScore, action: \.addictionScore)
            )
        } else if store.showResults {
            ResultsView(
                store: store.scope(state: \.results, action: \.results)
            )
        } else if store.showResultsLoading {
            ResultsLoadingView(
                store: store.scope(state: \.resultsLoading, action: \.resultsLoading)
            )
        } else if store.isOnboardingComplete {
            Text("Main App - Coming Soon")
        } else {
            OnboardingView(
                store: store.scope(state: \.onboarding, action: \.onboarding)
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
