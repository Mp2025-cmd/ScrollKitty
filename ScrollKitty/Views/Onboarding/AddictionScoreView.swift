import ComposableArchitecture
import SwiftUI

// MARK: - Feature
@Reducer
struct AddictionScoreFeature {
    @ObservableState
    struct State: Equatable {
        var userData: UserPhoneData?
        var userScore: Double = 0
        var recommendedUsage: Double = 2.0 // Science-based recommendation (2 hours/day)
        var userPercentage: Double = 0
        var recommendedPercentage: Double = 0

        // Animation states
        var userBarHeight: CGFloat = 0
        var recommendedBarHeight: CGFloat = 0
        var showWarning = false
        var showContinueButton = false
    }
    
    enum Action: Equatable {
        case onAppear
        case calculateScore(UserPhoneData)
        case animationCompleted
        case continueTapped
        case backTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case showNextScreen
            case goBack
        }
    }

    // Calculate severity multiplier based on survey responses (1.0 - 1.5x range)
    private func calculateSeverityMultiplier(_ data: UserPhoneData) -> Double {
        var multiplier = 1.0

        // High addiction indicators add to multiplier
        if data.addictionLevel == .yes || data.addictionLevel == .often {
            multiplier += 0.2
        }
        if data.sleepImpact == .almostEveryNight {
            multiplier += 0.15
        }
        if data.withoutPhoneAnxiety == .veryAnxious {
            multiplier += 0.15
        }

        return min(multiplier, 1.5) // Cap at 1.5x max
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case let .calculateScore(userData):
                state.userData = userData

                // Calculate user score (honest, simplified approach)
                let baseHours = userData.dailyHours
                let severityMultiplier = calculateSeverityMultiplier(userData)

                state.userScore = baseHours * severityMultiplier

                // Recommended usage is constant (2 hours/day - science based)
                state.recommendedUsage = 2.0

                // Calculate percentages for bar chart display
                let maxDisplayHours = 12.0 // Cap display at 12 hours
                state.userPercentage = min((state.userScore / maxDisplayHours) * 100, 100)
                state.recommendedPercentage = (state.recommendedUsage / maxDisplayHours) * 100 // ~16.7%

                return .none
                
            case .animationCompleted:
                state.showWarning = true
                state.showContinueButton = true
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

// MARK: - Animated Bar Graph Component
struct AnimatedBarGraph: View {
    let userPercentage: Double
    let recommendedPercentage: Double
    let onAnimationCompleted: () -> Void
    @State private var userBarHeight: CGFloat = 0
    @State private var recommendedBarHeight: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 36) {
            // User Score Bar
            VStack(spacing: 8) {
                ZStack(alignment: .bottom) {
                    // Background bar
                    RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.barGraph)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: DesignSystem.ComponentSize.barGraphWidth, height: DesignSystem.ComponentSize.barGraphHeight)

                    // Animated user bar
                    RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.barGraph)
                        .fill(DesignSystem.Colors.highlightOrange)
                        .frame(width: DesignSystem.ComponentSize.barGraphWidth, height: userBarHeight)
                        .animation(.easeOut(duration: 2.0), value: userBarHeight)

                    // Percentage text
                    Text("\(Int(userPercentage))%")
                        .font(DesignSystem.Typography.percentage25())
                        .tracking(DesignSystem.Typography.titleLetterSpacing)
                        .foregroundColor(DesignSystem.Colors.white)
                        .opacity(userBarHeight > 50 ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(1.5), value: userBarHeight)
                }

                Text("Your Usage")
                    .font(DesignSystem.Typography.subtitle())
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }

            // Recommended Bar
            VStack(spacing: 8) {
                ZStack(alignment: .bottom) {
                    // Background bar
                    RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.barGraph)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: DesignSystem.ComponentSize.barGraphWidth, height: DesignSystem.ComponentSize.barGraphHeight)

                    // Animated recommended bar
                    RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.barGraph)
                        .fill(DesignSystem.Colors.lightBlue)
                        .frame(width: DesignSystem.ComponentSize.barGraphWidth, height: recommendedBarHeight)
                        .animation(.easeOut(duration: 1.5).delay(0.5), value: recommendedBarHeight)

                    // Percentage text
                    Text("\(Int(recommendedPercentage))%")
                        .font(DesignSystem.Typography.percentage25())
                        .tracking(DesignSystem.Typography.titleLetterSpacing)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .opacity(recommendedBarHeight > 30 ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(1.0), value: recommendedBarHeight)
                }

                Text("Recommended")
                    .font(DesignSystem.Typography.subtitle())
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }
        }
        .onAppear {
            // Start animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                userBarHeight = CGFloat(userPercentage / 100 * DesignSystem.ComponentSize.barGraphHeight)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                recommendedBarHeight = CGFloat(recommendedPercentage / 100 * DesignSystem.ComponentSize.barGraphHeight)
            }

            // Trigger animation completion after all animations finish
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                onAnimationCompleted()
            }
        }
    }
}

// MARK: - View
struct AddictionScoreView: View {
    let store: StoreOf<AddictionScoreFeature>
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button
                HStack {
                    BackButton {
                        store.send(.backTapped)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Header
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Text("Analysis Complete")
                            .font(DesignSystem.Typography.title30())
                            .tracking(DesignSystem.Typography.titleLetterSpacing)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DesignSystem.Colors.primaryBlue)
                            .font(DesignSystem.Typography.icon24())
                    }
                    
                    Text("Here are your results...")
                        .font(DesignSystem.Typography.subtitle())
                        .foregroundColor(DesignSystem.Colors.textGray)
                }
                .padding(.top, 16)
                
                // Main Message
                VStack(spacing: 0) {
                    Text("Your daily usage is way above")
                    Text("recommended levels")
                }
                .font(DesignSystem.Typography.title24())
                .foregroundColor(DesignSystem.Colors.primaryText)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
                .padding(.horizontal, 16)

                // Animated Bar Graph
                AnimatedBarGraph(
                    userPercentage: store.userPercentage,
                    recommendedPercentage: store.recommendedPercentage,
                    onAnimationCompleted: {
                        store.send(.animationCompleted)
                    }
                )
                .padding(.top, 40)

                // Sarcastic Warning Message
                Text("You're above average — but not in a good way.")
                    .font(DesignSystem.Typography.subtitle())
                    .foregroundColor(DesignSystem.Colors.highlightOrange)
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)
                    .padding(.horizontal, 16)

                Spacer()
                
                // Continue Button
                PrimaryButton(title: "Continue") {
                    store.send(.continueTapped)
                }
                .padding(.bottom, 32)
                .opacity(store.showContinueButton ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: store.showContinueButton)

                
                // Disclaimer
                Text("*This result is an indication only and not a medical diagnosis.")
                    .font(DesignSystem.Typography.body12())
                    .foregroundColor(DesignSystem.Colors.textGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    AddictionScoreView(
        store: Store(
            initialState: AddictionScoreFeature.State(),
            reducer: { AddictionScoreFeature() }
        )
    )
}
