import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .buttonTextStyle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .primaryButtonStyle()
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Get Started") {}
        PrimaryButton(title: "Next") {}
    }
    .padding()
}
