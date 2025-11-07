import ComposableArchitecture
import SwiftUI

// MARK: - Feature
@Reducer
struct SolutionIntroFeature {
    @ObservableState
    struct State: Equatable {
        // No state needed for this static screen
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
struct SolutionIntroView: View {
    let store: StoreOf<SolutionIntroFeature>
    
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
                
                // Main Message
                VStack(spacing: 0) {
                    Text("The good news is that")
                    Text("Scroll Kitty")
                        .foregroundColor(DesignSystem.Colors.primaryBlue)
                    Text("can help you")
                    Text("get your time back!")
                }
                .font(DesignSystem.Typography.title30())
                .tracking(DesignSystem.Typography.titleLetterSpacing)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(0)
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Cat Image with Shadow
                ZStack(alignment: .bottom) {
                    VStack {
                        CatState.healthy.image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 280)
                    }
                    
                    CatShadow(width: 250, height: 5, opacity: 0.65)
                        .offset(y: -24)
                }
                
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
    SolutionIntroView(
        store: Store(
            initialState: SolutionIntroFeature.State(),
            reducer: { SolutionIntroFeature() }
        )
    )
}
