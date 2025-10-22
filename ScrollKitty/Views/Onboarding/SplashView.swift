import SwiftUI
import ComposableArchitecture

struct SplashView: View {
    let store: StoreOf<SplashFeature>
    
    var body: some View {
        ZStack {
            // Blue background
            DesignSystem.Colors.splashBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Cat Image
                Image("1_Healthy_Cheerful")
                    .resizable()
                    .scaledToFit()
                    .frame(width: DesignSystem.ComponentSize.catImageWidth,
                           height: DesignSystem.ComponentSize.catImageHeight)
                
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
