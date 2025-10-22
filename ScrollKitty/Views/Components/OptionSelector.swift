import SwiftUI

struct OptionSelector<Option>: View where Option: CaseIterable & Equatable & RawRepresentable, Option.RawValue == String {
    let options: [Option]
    let selectedOption: Option?
    let onSelect: (Option) -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                HStack {
                    Text(option.rawValue)
                        .bodyStyle()
                        .padding(.leading)
                    Spacer()
                    
                    Image(systemName: selectedOption == option ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selectedOption == option ? DesignSystem.Colors.primaryBlue : DesignSystem.Colors.textGray)
                        .padding(.trailing)
                }
                 .selectionOptionStyle(isSelected: selectedOption == option)
                .onTapGesture {
                    onSelect(option)
                }
            }
        }
    }
}

#Preview {
    enum PreviewOption: String, CaseIterable, Equatable, RawRepresentable {
        case optionA = "Option A"
        case optionB = "Option B"
        case optionC = "Option C"
    }
    
    return OptionSelector(
        options: PreviewOption.allCases,
        selectedOption: .optionB,
        onSelect: { _ in }
    )
    .padding()
}
