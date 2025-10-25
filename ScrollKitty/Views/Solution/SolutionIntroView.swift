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
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case showNextScreen
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .continueTapped:
                return .send(.delegate(.showNextScreen))
                
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
                // Status Bar (simulated)
                HStack {
                    Text("9:41")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Spacer()
                    
                    HStack(spacing: 7) {
                        Image(systemName: "cellularbars")
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        Image(systemName: "wifi")
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        Image(systemName: "battery.100")
                            .foregroundColor(DesignSystem.Colors.primaryText)
                    }
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
                .font(.custom("Sofia Pro-Bold", size: 30))
                .tracking(DesignSystem.Typography.titleLetterSpacing)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(0)
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Character Image
                Image("1_Healthy_Cheerful")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 237, height: 214)
                    .padding(.bottom, 40)
                
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
