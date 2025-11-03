import SwiftUI

struct HomeView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            // Dark background
            DesignSystem.Colors.dashboardBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Status Bar (Time, Signal, WiFi, Battery)
                HStack(spacing: 0) {
                    Text("9:41")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(hex: "#d9d9d9"))
                    
                    Spacer()
                    
                    HStack(spacing: 7) {
                        Image(systemName: "cellularbars")
                            .foregroundColor(Color(hex: "#d9d9d9"))
                        Image(systemName: "wifi")
                            .foregroundColor(Color(hex: "#d9d9d9"))
                        Image(systemName: "battery.100")
                            .foregroundColor(Color(hex: "#d9d9d9"))
                    }
                    .font(.system(size: 13, weight: .regular))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                
                // Title
                Text("Scroll Kitty")
                    .font(.custom("Sofia Pro-Bold", size: 36))
                    .tracking(-1)
                    .foregroundColor(.white)
                    .padding(.top, 16)
                
                Spacer()
                
                // Cat Image
                Image("1_Healthy_Cheerful")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 280)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // Score Section
                VStack(spacing: 16) {
                    // Percentage
                    Text("36%")
                        .font(.custom("Sofia Pro-Bold", size: 50))
                        .tracking(-1)
                        .foregroundColor(.white)
                    
                    // Progress Bar
                    ProgressBar(percentage: 36)
                        .frame(width: 256)
                    
                    // Usage Time
                    Text("1 hour 25 minutes")
                        .font(.custom("Sofia Pro-Semi_Bold", size: 24))
                        .foregroundColor(.white)
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
