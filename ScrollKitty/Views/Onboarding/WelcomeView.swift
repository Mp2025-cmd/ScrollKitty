import ComposableArchitecture
import SwiftUI

@Reducer
struct WelcomeFeature {
    @ObservableState
    struct State: Equatable {
        // No state needed for welcome screen
    }

    enum Action: Equatable {
        case getStartedTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case proceedToNextStep
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .getStartedTapped:
                return .send(.delegate(.proceedToNextStep))

            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - View

struct WelcomeView: View {
    let store: StoreOf<WelcomeFeature>
    
    var body: some View {
        ZStack {
            // White background
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Cat Image
                Image("1_Healthy_Cheerful")
                    .resizable()
                    .scaledToFit()
                    .frame(width: DesignSystem.ComponentSize.catImageWidth,
                           height: DesignSystem.ComponentSize.catImageHeight)

                VStack(spacing: 12) {
                    Text("Welcome to Scroll Kitty")
                        .largeTitleStyle()
                    
                    Text("Protect your focus and keep Scroll Kitty happy.")
                        .subtitleStyle()
                }
                
                Spacer()
                
                // Get Started Button
                PrimaryButton(title: "Get Started") {
                    store.send(.getStartedTapped)
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    WelcomeView(
        store: Store(
            initialState: WelcomeFeature.State(),
            reducer: { WelcomeFeature() }
        )
    )
}
