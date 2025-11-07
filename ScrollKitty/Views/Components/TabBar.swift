import SwiftUI

struct TabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color(hex: "#E8E8E8"))
            
            HStack(spacing: 0) {
                // Dashboard Tab
                Button {
                    selectedTab = 0
                } label: {
                    VStack(spacing: 8) {
                        Image("TabBar_Dashboard")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(selectedTab == 0 ? DesignSystem.Colors.primaryBlue : DesignSystem.Colors.secondaryText)
                        
                        Text("Dashboard")
                            .font(.custom("Sofia Pro-Regular", size: 12))
                            .foregroundColor(selectedTab == 0 ? DesignSystem.Colors.primaryBlue : DesignSystem.Colors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .opacity(selectedTab == 0 ? 1 : 0.5)
                }
                
                // Timeline Tab
                Button {
                    selectedTab = 1
                } label: {
                    VStack(spacing: 8) {
                        Image("TabBar_Timeline")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(selectedTab == 1 ? DesignSystem.Colors.primaryBlue : DesignSystem.Colors.secondaryText)
                        
                        Text("Timeline")
                            .font(.custom("Sofia Pro-Regular", size: 12))
                            .foregroundColor(selectedTab == 1 ? DesignSystem.Colors.primaryBlue : DesignSystem.Colors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .opacity(selectedTab == 1 ? 1 : 0.5)
                }
            }
            .background(DesignSystem.Colors.background)
        }
    }
}

#Preview {
    VStack {
        Spacer()
        TabBar(selectedTab: .constant(0))
    }
    .background(DesignSystem.Colors.dashboardBackground)
}
