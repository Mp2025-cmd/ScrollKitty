import SwiftUI

struct TimeOptionButton: View {
    let minutes: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text("\(minutes) minutes")
                    .font(.custom("Sofia Pro-Regular", size: 16))
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.ComponentSize.optionHeight)
            .background(DesignSystem.Colors.selectionBackground)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.selectionOption)
                    .stroke(
                        isSelected ? DesignSystem.Colors.selectionBorder : Color.gray,
                        lineWidth: isSelected ? DesignSystem.BorderWidth.selection : 0
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.selectionOption))
        }
    }
}

#Preview("Single Button - Selected") {
    TimeOptionButton(
        minutes: 5,
        isSelected: true,
        onTap: {}
    )
    .padding()
    .background(DesignSystem.Colors.background)
}

#Preview("Single Button - Unselected") {
    TimeOptionButton(
        minutes: 10,
        isSelected: false,
        onTap: {}
    )
    .padding()
    .background(DesignSystem.Colors.background)
}

#Preview("Grid Layout - 2x2") {
    VStack(spacing: 12) {
        HStack(spacing: 12) {
            TimeOptionButton(minutes: 5, isSelected: true, onTap: {})
            TimeOptionButton(minutes: 10, isSelected: false, onTap: {})
        }
        HStack(spacing: 12) {
            TimeOptionButton(minutes: 15, isSelected: false, onTap: {})
            TimeOptionButton(minutes: 30, isSelected: false, onTap: {})
        }
    }
    .padding()
    .background(DesignSystem.Colors.background)
}


