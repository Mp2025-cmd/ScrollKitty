import SwiftUI

struct TabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color(hex: "#1a252f"))
            
            HStack(spacing: 0) {
                // Dashboard Tab
                VStack(spacing: 8) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 24))
                    
                    Text("Dashboard")
                        .font(.custom("Sofia Pro-Regular", size: 12))
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTab == 0 ? Color(hex: "#bbdbff") : Color(hex: "#696969"))
                .padding(.vertical, 12)
                
                // Timeline Tab
                VStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 24))
                    
                    Text("Timeline")
                        .font(.custom("Sofia Pro-Regular", size: 12))
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTab == 1 ? Color(hex: "#bbdbff") : Color(hex: "#696969"))
                .padding(.vertical, 12)
            }
            .background(Color(hex: "#0d141e"))
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
