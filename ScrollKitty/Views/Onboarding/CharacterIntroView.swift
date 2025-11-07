import ComposableArchitecture
import SwiftUI

// MARK: - Feature
@Reducer
struct CharacterIntroFeature {
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
struct CharacterIntroView: View {
    let store: StoreOf<CharacterIntroFeature>
    
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
                
                // Title
                Text("Meet Scroll Kitty")
                    .font(.custom("Sofia Pro-Bold", size: 35))
                    .tracking(-2)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)
                
                // Subtitle
                VStack(spacing: 0) {
                    Text("Scroll Kitty is your friendly cat friend that loves")
                    Text("when you spend less time on your phone.")
                }
                .font(.custom("Sofia Pro-Medium", size: 16))
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(0)
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
    CharacterIntroView(
        store: Store(
            initialState: CharacterIntroFeature.State(),
            reducer: { CharacterIntroFeature() }
        )
    )
}
