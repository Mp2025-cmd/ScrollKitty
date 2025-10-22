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
        if store.isOnboardingComplete {
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
