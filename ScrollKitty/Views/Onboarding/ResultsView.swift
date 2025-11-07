import ComposableArchitecture
import SwiftUI

@Reducer
struct ResultsFeature {
    @ObservableState
    struct State: Equatable {
        // No state needed - this is just a static screen
    }
    
    enum Action: Equatable {
        case viewResultsTapped
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case showAddictionScore
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .viewResultsTapped:
                return .send(.delegate(.showAddictionScore))
                
            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - View

struct ResultsView: View {
    let store: StoreOf<ResultsFeature>
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Main Title
                VStack(spacing: 0) {
                    Text("Some not-so-good news.")
                        .font(.custom("Sofia Pro-Bold", size: 30))
                        .tracking(DesignSystem.Typography.titleLetterSpacing)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .multilineTextAlignment(.center)
                    
                    Text("And some great news...")
                        .font(.custom("Sofia Pro-Bold", size: 30))
                        .tracking(DesignSystem.Typography.titleLetterSpacing)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                // View Results Button
                PrimaryButton(title: "View Results") {
                    store.send(.viewResultsTapped)
                }
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    ResultsView(
        store: Store(
            initialState: ResultsFeature.State(),
            reducer: { ResultsFeature() }
        )
    )
}
