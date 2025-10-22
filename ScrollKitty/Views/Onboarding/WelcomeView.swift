import SwiftUI
import ComposableArchitecture

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
