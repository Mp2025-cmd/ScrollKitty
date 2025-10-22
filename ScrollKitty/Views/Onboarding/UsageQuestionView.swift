import SwiftUI
import ComposableArchitecture

struct UsageQuestionView: View {
    let store: StoreOf<UsageQuestionFeature>
    
    var body: some View {
        ZStack {
            // White background
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                ProgressIndicator(currentStep: 2, totalSteps: 3)
                    .padding(.top, 24)
                
                Spacer()
                    .frame(minHeight: 24)
                
                // Title
                VStack(spacing: 8) {
                    Text("How many hours do you")
                    Text("spend on your phone")
                    Text("each day?")
                }
                .largeTitleStyle()
                
                Spacer()
                    .frame(minHeight: 12)
                
                // Subtitle
                Text("answer to the best of your knowledge")
                    .subtitleStyle()
                
                Spacer()
                    .frame(minHeight: 32)
                
                // Options
                VStack(spacing: 12) {
                    ForEach(UsageQuestionFeature.HourOption.allCases, id: \.self) { option in
                        HStack {
                            Text(option.rawValue)
                                .bodyStyle()
                            
                            Spacer()
                            
                            Image(systemName: store.selectedOption == option ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(store.selectedOption == option ? DesignSystem.Colors.primaryBlue : DesignSystem.Colors.textGray)
                        }
                        .selectionOptionStyle(isSelected: store.selectedOption == option)
                        .onTapGesture {
                            store.send(.optionSelected(option))
                        }
                    }
                }
                
                Spacer()
                
                // Next Button
                PrimaryButton(title: "Next") {
                    store.send(.nextTapped)
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    UsageQuestionView(
        store: Store(
            initialState: UsageQuestionFeature.State(),
            reducer: { UsageQuestionFeature() }
        )
    )
}
