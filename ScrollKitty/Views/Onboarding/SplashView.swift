import ComposableArchitecture
import SwiftUI

@Reducer
struct SplashFeature {
    @Dependency(\.continuousClock) var clock
    
    @ObservableState
    struct State: Equatable {
        // No state needed - timer is managed by the effect
    }
    
    enum Action: Equatable {
        case onAppear
        case timerTick
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case splashCompleted
        }
    }
    
    nonisolated struct CancelID: Hashable, Sendable {
        static let autoAdvanceTimer = Self()
    }
    
    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .onAppear:
                // Start timer for auto-advance after 2 seconds
                return .run { send in
                    try await clock.sleep(for: .seconds(2))
                    await send(.timerTick)
                }
                .cancellable(id: CancelID.autoAdvanceTimer)
                
            case .timerTick:
                return .send(.delegate(.splashCompleted))
                
            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - View

struct SplashView: View {
    let store: StoreOf<SplashFeature>
    
    var body: some View {
        ZStack {
            // Blue background
            DesignSystem.Colors.splashBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Cat Image with Shadow
                ZStack(alignment: .bottom) {
                    VStack {
                        Image("1_Healthy_Cheerful")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 280)
                    }
                    
                    CatShadow(width: 250, height: 5, opacity: 0.65)
                        .offset(y: -24)
                }
                
                // Title
                Text("Scroll Kitty")
                    .splashTitleStyle()
                
                Spacer()
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    SplashView(
        store: Store(
            initialState: SplashFeature.State(),
            reducer: { SplashFeature() }
        )
    )
}
