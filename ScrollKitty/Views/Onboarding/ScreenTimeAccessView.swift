import ComposableArchitecture
import SwiftUI

// MARK: - Feature
@Reducer
struct ScreenTimeAccessFeature {
    @ObservableState
    struct State: Equatable {
        // No state needed for this empty screen
    }
    
    enum Action: Equatable {
        case onAppear
        case continueTapped
        case backTapped
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case showNextScreen
            case goBack
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .continueTapped:
                return .send(.delegate(.showNextScreen))
                
            case .backTapped:
                return .send(.delegate(.goBack))
                
            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - View
struct ScreenTimeAccessView: View {
    let store: StoreOf<ScreenTimeAccessFeature>
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button
                HStack {
                    BackButton {
                        store.send(.backTapped)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Spacer()
                
                // Placeholder content - will be implemented later
                VStack(spacing: 24) {
                    Text("Allow access to Screen Time")
                        .font(.custom("Sofia Pro-Bold", size: 30))
                        .tracking(DesignSystem.Typography.titleLetterSpacing)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .multilineTextAlignment(.center)
                    
                    Text("This screen will be implemented later")
                        .font(.custom("Sofia Pro-Medium", size: 16))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Continue Button
                PrimaryButton(title: "Continue") {
                    store.send(.continueTapped)
                }
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    ScreenTimeAccessView(
        store: Store(
            initialState: ScreenTimeAccessFeature.State(),
            reducer: { ScreenTimeAccessFeature() }
        )
    )
}
