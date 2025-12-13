import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .buttonTextStyle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .disabled(!isEnabled)
        .primaryButtonStyle()
        .opacity(isEnabled ? 1.0 : 0.4)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Get Started") {}
        PrimaryButton(title: "Next") {}
        PrimaryButton(title: "Disabled", isEnabled: false) {}
    }
    .padding()
}
