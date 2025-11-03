import ComposableArchitecture
import SwiftUI

@Reducer
struct CommitmentFeature {
    @ObservableState
    struct State: Equatable {
        var isCommitted: Bool = false
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case continueTapped
        case backTapped
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case showNextScreen
            case goBack
        }
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .continueTapped:
                return .send(.delegate(.showNextScreen))
                
            case .backTapped:
                return .send(.delegate(.goBack))
                
            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - View
struct CommitmentView: View {
    @Bindable var store: StoreOf<CommitmentFeature>
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Back button
                HStack {
                    BackButton {
                        store.send(.backTapped)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Spacer()
                
                // Cat Image
                Image("1_Healthy_Cheerful")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding(.horizontal, 40)

                VStack(spacing: 8) {
                    Text("Ready to take back control?")
                        .font(.custom("Sofia Pro-Bold", size: 24))
                        .tracking(-1)
                        .foregroundColor(DesignSystem.Colors.primaryText)

                    Text("Make a promise to yourself")
                        .font(.custom("Sofia Pro-Regular", size: 16))
                        .foregroundColor(DesignSystem.Colors.textGray)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                
                // I commit to section
                VStack(alignment: .leading, spacing: 26) {
                    Text("I commit to:")
                        .font(.custom("Sofia Pro-Bold", size: 20))
                        .tracking(-1)
                        .foregroundColor(DesignSystem.Colors.primaryText)

                    // Light blue box with commitments
                    VStack(alignment: .leading, spacing: 12) {
                        CommitmentItem(text: "Guarding my focus and attention.")
                        CommitmentItem(text: "Building healthier digital habits.")
                        CommitmentItem(text: "Reclaiming my time from the scroll.")
                        CommitmentItem(text: "Protecting Scroll Kitty as I protect my mind.")
                    }
                    .padding(20)
                    .background(Color(hex: "#bbdbff"))
                    .cornerRadius(30)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
                VStack(alignment:.center,spacing: 30) {
                    CommitmentCheckbox(
                        isSelected: $store.isCommitted
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 50)
                            .fill(DesignSystem.Colors.lightBlue)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(DesignSystem.Colors.primaryBlue, lineWidth: 2)
                    )
                    .padding(.horizontal, 38)
                    
                    // Congratulations message (always in hierarchy, visibility controlled by opacity)
                    Text("🎉 Congratulations on taking the first step! 🎉")
                        .font(.custom("Sofia Pro-Regular", size: 12))
                        .foregroundColor(DesignSystem.Colors.textGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .opacity(store.isCommitted ? 1 : 0)
                    
                    PrimaryButton(title: "Continue") {
                        store.send(.continueTapped)
                    }
                    .opacity(store.isCommitted ? 1 : 0)
                    .disabled(!store.isCommitted)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

// MARK: - Commitment Item Component
struct CommitmentItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("•")
                .font(.custom("Sofia Pro-Regular", size: 16))
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            Text(text)
                .font(.custom("Sofia Pro-Regular", size: 16))
                .foregroundColor(DesignSystem.Colors.primaryText)
                .lineLimit(nil)
            
            Spacer()
        }
    }
}

// MARK: - Commitment Checkbox
struct CommitmentCheckbox: View {
    @Binding var isSelected: Bool
    
    var body: some View {
        HStack  {
            // Checkmark
           
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 18))
            }
            else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
            }

            Text("I'm ready to commit!")
                .font(.custom("Sofia Pro-Regular", size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(DesignSystem.Colors.primaryText)
                 
            Toggle("", isOn: $isSelected)
                .labelsHidden()
        }
        
    }
}

#Preview {
    CommitmentView(
        store: Store(
            initialState: CommitmentFeature.State(),
            reducer: { CommitmentFeature() }
        )
    )
}
