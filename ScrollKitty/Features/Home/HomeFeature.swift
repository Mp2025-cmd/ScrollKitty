import ComposableArchitecture
import SwiftUI

@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        // Stateless for now - can add state as needed
    }
    
    enum Action: Equatable {
        case tabSelected(Int)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .tabSelected:
                // Handle tab selection - can navigate to other screens later
                return .none
            }
        }
    }
}
