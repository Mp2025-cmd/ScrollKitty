import ComposableArchitecture
import SwiftUI

// MARK: - Feature
@Reducer
struct AddictionScoreFeature {
    @ObservableState
    struct State: Equatable {
        var userData: UserPhoneData?
        var userScore: Double = 0
        var populationAverage: Double = 0
        var userPercentage: Double = 0
        var averagePercentage: Double = 0
        
        // Animation states
        var userBarHeight: CGFloat = 0
        var averageBarHeight: CGFloat = 0
        var showWarning = false
        var showContinueButton = false
    }
    
    enum Action: Equatable {
        case onAppear
        case calculateScore(UserPhoneData)
        case animationCompleted
        case continueTapped
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case showNextScreen
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case let .calculateScore(userData):
                state.userData = userData
                
                // Calculate user score with GUILT TRIP multipliers
                let baseHours = userData.dailyHours
                let addictionMultiplier = userData.addictionLevel.multiplier
                let sleepMultiplier = userData.sleepImpact.multiplier
                let anxietyMultiplier = userData.withoutPhoneAnxiety.multiplier
                let idleMultiplier = userData.idleCheckFrequency.multiplier
                
                // GUILT TRIP: Add extra penalty for high usage
                let guiltTripMultiplier = baseHours > 6 ? 1.3 : 1.0 // Extra 30% penalty for heavy users
                
                state.userScore = baseHours * addictionMultiplier * sleepMultiplier * anxietyMultiplier * idleMultiplier * guiltTripMultiplier
                
                // Get population average based on age (MUCH LOWER NOW)
                state.populationAverage = userData.ageGroup.populationAverage
                
                // Calculate percentages (normalize to 0-100 scale)
                let maxPossibleScore = 20.0 // Increased from 15.0 to accommodate higher multipliers
                state.userPercentage = min((state.userScore / maxPossibleScore) * 100, 100)
                state.averagePercentage = min((state.populationAverage / maxPossibleScore) * 100, 100)
                
                return .none
                
            case .animationCompleted:
                state.showWarning = true
                state.showContinueButton = true
                return .none
                
            case .continueTapped:
                return .send(.delegate(.showNextScreen))
                
            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - Animated Bar Graph Component
struct AnimatedBarGraph: View {
    let userPercentage: Double
    let averagePercentage: Double
    @State private var userBarHeight: CGFloat = 0
    @State private var averageBarHeight: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 36) {
            // User Score Bar
            VStack(spacing: 8) {
                ZStack(alignment: .bottom) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 67, height: 295)

                    // Animated user bar
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.99, green: 0.31, blue: 0.06)) // #fd4e0f
                        .frame(width: 67, height: userBarHeight)
                        .animation(.easeOut(duration: 2.0), value: userBarHeight)

                    // Percentage text
                    Text("\(Int(userPercentage))%")
                        .font(.custom("Sofia Pro-Bold", size: 25))
                        .tracking(DesignSystem.Typography.titleLetterSpacing)
                        .foregroundColor(.white)
                        .opacity(userBarHeight > 50 ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(1.5), value: userBarHeight)
                }

                Text("Your Score")
                    .font(.custom("Sofia Pro-Medium", size: 16))
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }
            
            // Average Bar
            VStack(spacing: 8) {
                ZStack(alignment: .bottom) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 67, height: 295)
                    
                    // Animated average bar
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.73, green: 0.86, blue: 1.0)) // #bbdbff
                        .frame(width: 67, height: averageBarHeight)
                        .animation(.easeOut(duration: 1.5).delay(0.5), value: averageBarHeight)
                    
                    // Percentage text
                    Text("\(Int(averagePercentage))%")
                        .font(.custom("Sofia Pro-Bold", size: 25))
                        .tracking(DesignSystem.Typography.titleLetterSpacing)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .opacity(averageBarHeight > 30 ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(1.0), value: averageBarHeight)
                }
                
                Text("Average")
                    .font(.custom("Sofia Pro-Medium", size: 16))
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }
        }
        .onAppear {
            // Start animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                userBarHeight = CGFloat(userPercentage / 100 * 295)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                averageBarHeight = CGFloat(averagePercentage / 100 * 295)
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
                // Status Bar (simulated)
                HStack {
                    Text("9:41")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Spacer()
                    
                    HStack(spacing: 7) {
                        Image(systemName: "cellularbars")
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        Image(systemName: "wifi")
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        Image(systemName: "battery.100")
                            .foregroundColor(DesignSystem.Colors.primaryText)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Header
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Text("Analysis Complete")
                            .font(.custom("Sofia Pro-Bold", size: 30))
                            .tracking(DesignSystem.Typography.titleLetterSpacing)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DesignSystem.Colors.primaryBlue)
                            .font(.system(size: 24))
                    }
                    
                    Text("Here are your results...")
                        .font(.custom("Sofia Pro-Medium", size: 16))
                        .foregroundColor(DesignSystem.Colors.textGray)
                }
                .padding(.top, 16)
                
                // Main Message
                VStack(spacing: 0) {
                    Text("Your daily usage is higher than")
                    Text("most people your age")
                }
                .font(.custom("Sofia Pro-Medium", size: 24))
                .foregroundColor(DesignSystem.Colors.primaryText)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
                .padding(.horizontal, 16)
                
                // Animated Bar Graph
                AnimatedBarGraph(
                    userPercentage: store.userPercentage,
                    averagePercentage: store.averagePercentage
                )
                .padding(.top, 40)

                // GUILT TRIP Warning Message
                Text("You're WAY above average — this is actually concerning.")
                    .font(.custom("Sofia Pro-Medium", size: 16))
                    .foregroundColor(Color(red: 0.99, green: 0.31, blue: 0.06)) // #fd4e0f
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)
                    .padding(.horizontal, 16)

                Spacer()
                
                // Continue Button
                PrimaryButton(title: "Continue") {
                    store.send(.continueTapped)
                }
                .opacity(store.showContinueButton ? 1 : 0)
                .animation(.easeInOut(duration: 0.5).delay(3.0), value: store.showContinueButton)
                .padding(.bottom, 32)
                
                // Disclaimer
                Text("*This result is an indication only and not a medical diagnosis.")
                    .font(.custom("Sofia Pro-Regular", size: 12))
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
