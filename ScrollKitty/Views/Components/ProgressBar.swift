import SwiftUI

struct ProgressBar: View {
    let percentage: Double
    let filledColor: Color
    let backgroundColor: Color = Color(hex: "#E8E8E8")
    
    init(percentage: Double, filledColor: Color = DesignSystem.Colors.progressBarFill) {
        self.percentage = percentage
        self.filledColor = filledColor
    }
    
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
