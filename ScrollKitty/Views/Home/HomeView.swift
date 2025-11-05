import SwiftUI

struct HomeView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            // White background
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Status Bar (Time, Signal, WiFi, Battery)
                HStack(spacing: 0) {
                    Text("9:41")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 7) {
                        Image(systemName: "cellularbars")
                            .foregroundColor(DesignSystem.Colors.gray)
                        Image(systemName: "wifi")
                            .foregroundColor(DesignSystem.Colors.gray)
                        Image(systemName: "battery.100")
                            .foregroundColor(DesignSystem.Colors.gray)
                    }
                    .font(.system(size: 13, weight: .regular))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                
                // Title
                Text("Scroll Kitty")
                    .font(.custom("Sofia Pro-Bold", size: 36))
                    .tracking(-1)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .padding(.top, 16)
                
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
                
                
                // Score Section
                VStack(spacing: 16) {
                    // Percentage
                    Text("36%")
                        .font(.custom("Sofia Pro-Bold", size: 50))
                        .tracking(-1)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    // Progress Bar
                    ProgressBar(percentage: 36, filledColor: Color(hex: "#00c54f"))
                        .frame(width: 256)
                    
                    // Usage Time
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
