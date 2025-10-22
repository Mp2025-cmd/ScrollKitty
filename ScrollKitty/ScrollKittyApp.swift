//
//  ScrollKittyApp.swift
//  ScrollKitty
//
//  Created by Peter on 10/19/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct ScrollKittyApp: App {
    let store = Store(
        initialState: AppFeature.State(),
        reducer: { AppFeature() }
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
