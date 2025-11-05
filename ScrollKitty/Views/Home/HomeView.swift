import SwiftUI

struct HomeView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
             DesignSystem.Colors.background
                .ignoresSafeArea()
            
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
                
                // Tab Bar
                TabBar(selectedTab: $selectedTab)
            }
        }
    }
}

#Preview {
    HomeView()
}
