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
        if store.showSolutionIntro {
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
