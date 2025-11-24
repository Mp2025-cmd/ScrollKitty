import SwiftUI

struct OptionSelector<Option>: View where Option: CaseIterable & Equatable & RawRepresentable, Option.RawValue == String, Option: Hashable {
    // Mode 1: Single Selection
    var selectedOption: Option?
    var onSelect: ((Option) -> Void)?
    
    // Mode 2: Multi Selection
    var selectedOptions: Set<Option>?
    var onToggle: ((Option) -> Void)?
    
    // Initializer for Single Selection
    init(options: [Option], selectedOption: Option?, onSelect: @escaping (Option) -> Void) {
        self.options = options
        self.selectedOption = selectedOption
        self.onSelect = onSelect
        self.selectedOptions = nil
        self.onToggle = nil
    }
    
    // Initializer for Multi Selection
    init(options: [Option], selectedOptions: Set<Option>, onToggle: @escaping (Option) -> Void) {
        self.options = options
        self.selectedOption = nil
        self.onSelect = nil
        self.selectedOptions = selectedOptions
        self.onToggle = onToggle
    }
    
    let options: [Option]
    
    private var isMultiSelect: Bool {
        selectedOptions != nil
    }
    
    var body: some View {
        VStack(spacing: 25) {
            ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                HStack {
                    Text(option.rawValue)
                        .bodyStyle()
                        .padding(.leading)
                    Spacer()

                    Image(systemName: iconName(for: option))
                        .foregroundColor(isSelected(option) ? DesignSystem.Colors.primaryBlue : DesignSystem.Colors.textGray)
                        .padding(.trailing)
                }
                .frame(maxWidth: .infinity)
                .selectionOptionStyle(isSelected: isSelected(option))
                .onTapGesture {
                    if isMultiSelect {
                        onToggle?(option)
                    } else {
                        onSelect?(option)
                    }
                }
            }
        }
    }
    
    private func isSelected(_ option: Option) -> Bool {
        if isMultiSelect {
            return selectedOptions?.contains(option) ?? false
        } else {
            return selectedOption == option
        }
    }
    
    private func iconName(for option: Option) -> String {
        let selected = isSelected(option)
        if isMultiSelect {
            return selected ? "checkmark.square.fill" : "square"
        } else {
            return selected ? "checkmark.circle.fill" : "circle"
        }
    }
}

#Preview {
    enum PreviewOption: String, CaseIterable, Equatable, RawRepresentable {
        case optionA = "Option A"
        case optionB = "Option B"
        case optionC = "Option C"
    }
    
    return VStack {
        Text("Single Select")
        OptionSelector(
            options: PreviewOption.allCases,
            selectedOption: .optionB,
            onSelect: { _ in }
        )
        
        Text("Multi Select")
        OptionSelector(
            options: PreviewOption.allCases,
            selectedOptions: [.optionA, .optionC],
            onToggle: { _ in }
        )
    }
    .padding()
}
