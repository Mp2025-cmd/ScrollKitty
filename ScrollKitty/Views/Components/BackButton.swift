import SwiftUI

struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primaryText)
        }
    }
}

#Preview {
    BackButton {
        print("Back tapped")
    }
}
