import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: StoreOf<HomeFeature>
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            if store.selectedTab == 0 {
                // Dashboard View
                dashboardContent
            } else {
                // Timeline View
                TimelineView()
            }
            
            VStack {
                Spacer()
                
                // Tab Bar
                TabBar(
                    selectedTab: Binding(
                        get: { store.selectedTab },
                        set: { store.send(.tabSelected($0)) }
                    )
                )
            }
        }
    }
    
    @ViewBuilder
    private var dashboardContent: some View {
        VStack(spacing: 0) {
            Text("Scroll Kitty")
                .font(.custom("Sofia Pro-Bold", size: 36))
                .tracking(-1)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .padding(.top, 16)
            
            Spacer()
            
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
            
            VStack(spacing: 16) {
                // Percentage
                Text("36%")
                    .font(.custom("Sofia Pro-Bold", size: 50))
                    .tracking(-1)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                ProgressBar(percentage: 36, filledColor: Color(hex: "#00c54f"))
                    .frame(width: 256)
                
                Text("1 hour 25 minutes")
                    .font(.custom("Sofia Pro-Semi_Bold", size: 24))
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
    }
}

#Preview {
    HomeView(
        store: Store(
            initialState: HomeFeature.State(),
            reducer: { HomeFeature() }
        )
    )
}
