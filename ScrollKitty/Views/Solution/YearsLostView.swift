import ComposableArchitecture
import SwiftUI

// MARK: - Feature
@Reducer
struct YearsLostFeature {
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
struct YearsLostView: View {
    let store: StoreOf<YearsLostFeature>
    
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
                    Text("At this pace, you'll spend")
                    Text("17 years")
                        .foregroundColor(DesignSystem.Colors.primaryBlue)
                    Text("of your life looking at a screen.")
                    Text("That's decades you")
                    Text("could be living.")
                }
                .font(.custom("Sofia Pro-Bold", size: 30))
                .tracking(DesignSystem.Typography.titleLetterSpacing)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(0)
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Character Image
                Image("3_Tired_Low-Energy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 262, height: 215)
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
    YearsLostView(
        store: Store(
            initialState: YearsLostFeature.State(),
            reducer: { YearsLostFeature() }
        )
    )
}
