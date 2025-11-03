import SwiftUI

struct ProgressBar: View {
    let percentage: Double
    let filledColor: Color = Color(hex: "#00c54f")
    let backgroundColor: Color = Color(hex: "#182430")
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background bar
                RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.progressBar)
                    .fill(backgroundColor)
                
                // Filled progress
                RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.progressBar)
                    .fill(filledColor)
                    .frame(width: geometry.size.width * (percentage / 100))
            }
        }
        .frame(height: 14)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBar(percentage: 36)
        ProgressBar(percentage: 75)
        ProgressBar(percentage: 100)
    }
    .padding()
    .background(DesignSystem.Colors.dashboardBackground)
}
