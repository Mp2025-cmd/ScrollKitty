import ComposableArchitecture
import SwiftUI
import UIKit

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
        case triggerCommitmentHaptic
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
                // Trigger haptic when commitment is made
                if state.isCommitted {
                    return .send(.triggerCommitmentHaptic)
                }
                return .none
                
            case .continueTapped:
                return .send(.delegate(.showNextScreen))
                
            case .backTapped:
                return .send(.delegate(.goBack))
                
            case .triggerCommitmentHaptic:
                return .run { _ in
                    await MainActor.run {
                        // Success notification haptic
                        let notificationGenerator = UINotificationFeedbackGenerator()
                        notificationGenerator.prepare()
                        notificationGenerator.notificationOccurred(.success)
                    }
                    
                    // Heavy impact after short delay for emphasis
                    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                    
                    await MainActor.run {
                        let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
                        impactGenerator.prepare()
                        impactGenerator.impactOccurred()
                    }
                }
                
            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - View
struct CommitmentView: View {
    @Bindable var store: StoreOf<CommitmentFeature>
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 13) {
                Spacer()
                 HStack {
                    BackButton {
                        store.send(.backTapped)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                 
                
                // Cat Image with Shadow
                ZStack(alignment: .bottom) {
                    VStack {
                        Image("1_Healthy_Cheerful")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 280)
                    }
                    
                    CatShadow(width: 250, height: 5, opacity: 0.65)
                        .offset(y: -24)
                }

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
                        .padding(.leading)

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
                        .font(.custom("Sofia Pro-Regular", size: 18))
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

            if showConfetti {
                ConfettiView()
            }
        }
        .onChange(of: store.isCommitted) { oldValue, newValue in
            if !oldValue && newValue {
                // Trigger confetti when commitment is made
                withAnimation {
                    showConfetti = true
                }
                
                // Hide confetti after animation completes (extended duration)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    withAnimation {
                        showConfetti = false
                    }
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

// MARK: - Confetti View
struct ConfettiView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<80, id: \.self) { index in
                    ConfettiPiece(index: index, screenSize: geometry.size)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - Confetti Piece
struct ConfettiPiece: View {
    let index: Int
    let screenSize: CGSize
    
    @State private var position = CGPoint.zero
    @State private var opacity: Double = 1
    @State private var rotation: Double = 0
    @State private var scale: Double = 1
    
    let colors: [Color] = [
        Color(hex: "#FF6B6B"), // Red
        Color(hex: "#4ECDC4"), // Teal
        Color(hex: "#FFE66D"), // Yellow
        Color(hex: "#95E1D3"), // Mint
        Color(hex: "#F38181"), // Pink
        Color(hex: "#AA96DA"), // Purple
        Color(hex: "#FCBAD3")  // Light Pink
    ]
    
    let shapes = ["circle", "square", "triangle"]
    
    var body: some View {
        Group {
            if shapes[index % shapes.count] == "circle" {
                Circle()
                    .fill(colors[index % colors.count])
                    .frame(width: 10, height: 10)
            } else if shapes[index % shapes.count] == "square" {
                Rectangle()
                    .fill(colors[index % colors.count])
                    .frame(width: 8, height: 8)
            } else {
                Triangle()
                    .fill(colors[index % colors.count])
                    .frame(width: 10, height: 10)
            }
        }
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))
        .position(position)
        .opacity(opacity)
        .onAppear {
            // Start from random points across the screen
            let startX = CGFloat.random(in: 0...screenSize.width)
            let startY = CGFloat.random(in: -100...screenSize.height * 0.3)
            position = CGPoint(x: startX, y: startY)
            
            // Random animation parameters for variety
            let duration = Double.random(in: 3.5...5.0)
            let delay = Double.random(in: 0...0.8)
            
            // Random fall trajectory
            let horizontalDrift = CGFloat.random(in: -150...150)
            let finalY = screenSize.height + CGFloat.random(in: 50...200)
            let finalX = startX + horizontalDrift
            
            // Animate the fall
            withAnimation(.easeIn(duration: duration).delay(delay)) {
                position = CGPoint(x: finalX, y: finalY)
                rotation = Double.random(in: 360...1080)
                scale = Double.random(in: 0.3...1.2)
            }
            
            // Fade out near the end
            withAnimation(.easeIn(duration: duration * 0.4).delay(delay + duration * 0.6)) {
                opacity = 0
            }
        }
    }
}

// Triangle shape for variety
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
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
