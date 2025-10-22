import SwiftUI

struct ProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    var fillWidth: CGFloat {
        let totalWidth = DesignSystem.ComponentSize.progressBarWidth
        let segmentWidth = totalWidth / CGFloat(totalSteps)
        return segmentWidth * CGFloat(currentStep)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.progressBar)
                    .fill(DesignSystem.Colors.progressBarBackground)
                    .frame(height: DesignSystem.ComponentSize.progressBarHeight)
                
                // Fill
                RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.progressBar)
                    .fill(DesignSystem.Colors.progressBarFill)
                    .frame(width: fillWidth, height: DesignSystem.ComponentSize.progressBarHeight)
            }
            .frame(width: DesignSystem.ComponentSize.progressBarWidth)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressIndicator(currentStep: 1, totalSteps: 3)
        ProgressIndicator(currentStep: 2, totalSteps: 3)
        ProgressIndicator(currentStep: 3, totalSteps: 3)
    }
    .padding()
}
