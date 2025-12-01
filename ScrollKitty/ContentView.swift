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
