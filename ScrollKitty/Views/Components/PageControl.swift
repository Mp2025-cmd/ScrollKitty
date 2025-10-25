import SwiftUI

struct PageControl: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? DesignSystem.Colors.primaryText : DesignSystem.Colors.primaryText.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.clear)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        PageControl(currentPage: 0, totalPages: 5)
        PageControl(currentPage: 2, totalPages: 5)
        PageControl(currentPage: 4, totalPages: 5)
    }
    .background(DesignSystem.Colors.background)
}
