import ComposableArchitecture
import SwiftUI
import Charts

// MARK: - Feature
@Reducer
struct AddictionScoreFeature {
    @ObservableState
    struct State: Equatable {
        var userData: UserPhoneData?
        var userHours: Double = 0
        var userScore: Double = 0
        var recommendedHours: Double = 2.0
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

    // Used downstream (YearsLost). Not used for the chart on this screen.
    private func calculateSeverityMultiplier(_ data: UserPhoneData) -> Double {
        var multiplier = 1.0

        if data.addictionLevel == .yes || data.addictionLevel == .often {
            multiplier += 0.2
        }
        if data.sleepImpact == .almostEveryNight {
            multiplier += 0.15
        }
        if data.withoutPhoneAnxiety == .veryAnxious {
            multiplier += 0.15
        }

        return min(multiplier, 1.5)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case let .calculateScore(userData):
                state.userData = userData

                state.userHours = userData.dailyHours
                state.recommendedHours = 2.0
                state.userScore = userData.dailyHours * calculateSeverityMultiplier(userData)

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

// MARK: - Bullet Graph (Usage vs Recommended)
private struct UsageBulletChart: View {
    let userHours: Double
    let recommendedHours: Double
    let onAnimationCompleted: () -> Void

    @State private var animatedUserHours: Double = 0

    private var axisMaxHours: Double {
        let maxHours = max(userHours, recommendedHours)
        return max(maxHours * 1.2, 1)
    }

    private var formattedUserTime: String {
        UsageBulletChart.formatHours(userHours)
    }

    private var formattedRecommendedTime: String {
        UsageBulletChart.formatHours(recommendedHours)
    }

    private var overageColor: Color {
        if userHours >= (recommendedHours * 2) {
            return DesignSystem.Colors.highlightRed
        } else {
            return DesignSystem.Colors.highlightOrange
        }
    }

    var body: some View {
        VStack(spacing: 14) {
            Chart {
                BarMark(
                    x: .value("Hours", axisMaxHours),
                    y: .value("Metric", "Usage")
                )
                .foregroundStyle(DesignSystem.Colors.progressBarBackground)
                .cornerRadius(6)

                BarMark(
                    xStart: .value("Start", 0),
                    xEnd: .value("Within", min(animatedUserHours, recommendedHours)),
                    y: .value("Metric", "Usage")
                )
                .foregroundStyle(DesignSystem.Colors.progressBarFill)
                .cornerRadius(6)

                if animatedUserHours > recommendedHours {
                    BarMark(
                        xStart: .value("Recommended", recommendedHours),
                        xEnd: .value("Over", animatedUserHours),
                        y: .value("Metric", "Usage")
                    )
                    .foregroundStyle(overageColor)
                    .cornerRadius(6)
                }

                RuleMark(x: .value("Recommended", recommendedHours))
                    .foregroundStyle(DesignSystem.Colors.textGray)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [4]))
            }
            .chartXScale(domain: 0...axisMaxHours)
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(position: .bottom, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine()
                        .foregroundStyle(DesignSystem.Colors.progressBarBackground)
                    AxisTick()
                        .foregroundStyle(DesignSystem.Colors.textGray)
                    AxisValueLabel {
                        if let hours = value.as(Double.self) {
                            Text("\(Int(hours))h")
                                .font(DesignSystem.Typography.body12())
                                .foregroundColor(DesignSystem.Colors.textGray)
                        }
                    }
                }
            }
            .frame(height: 64)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your usage")
                        .font(DesignSystem.Typography.body12())
                        .foregroundColor(DesignSystem.Colors.textGray)
                    Text(formattedUserTime)
                        .font(DesignSystem.Typography.title24())
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Recommended")
                        .font(DesignSystem.Typography.body12())
                        .foregroundColor(DesignSystem.Colors.textGray)
                    Text(formattedRecommendedTime)
                        .font(DesignSystem.Typography.title24())
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animatedUserHours = userHours
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.35) {
                onAnimationCompleted()
            }
        }
    }

    static func formatHours(_ hours: Double) -> String {
        let totalMinutes = max(0, Int((hours * 60).rounded()))
        let displayHours = totalMinutes / 60
        let displayMinutes = totalMinutes % 60

        if displayHours == 0 {
            return "\(displayMinutes)m"
        }
        if displayMinutes == 0 {
            return "\(displayHours)h"
        }
        return "\(displayHours)h \(displayMinutes)m"
    }
}

// MARK: - View
struct AddictionScoreView: View {
    let store: StoreOf<AddictionScoreFeature>

    private var overByText: String? {
        guard store.userHours > store.recommendedHours else { return nil }
        return UsageBulletChart.formatHours(store.userHours - store.recommendedHours)
    }

    private var reflectionTitle: String {
        "Here’s how your day compares"
    }

    private var reflectionSubtitle: String {
        "to the recommended limit"
    }

    private var reflectionNudge: String {
        "You’re trending high. Your future self won’t thank the scroll."
    }

    private var reflectionOverByLine: String? {
        guard let overByText else { return nil }
        return "\(overByText) over recommended"
    }
    
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
                    Text(reflectionTitle)
                    Text(reflectionSubtitle)
                }
                .font(DesignSystem.Typography.title24())
                .foregroundColor(DesignSystem.Colors.primaryText)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
                .padding(.horizontal, 16)

                UsageBulletChart(
                    userHours: store.userHours,
                    recommendedHours: store.recommendedHours,
                    onAnimationCompleted: {
                        store.send(.animationCompleted)
                    }
                )
                .padding(.top, 40)

                // Sarcastic Warning Message
                VStack(spacing: 6) {
                    Text(reflectionNudge)
                        .font(DesignSystem.Typography.subtitle())
                        .foregroundColor(DesignSystem.Colors.highlightOrange)
                        .multilineTextAlignment(.center)

                    if let reflectionOverByLine {
                        Text(reflectionOverByLine)
                            .font(DesignSystem.Typography.body12())
                            .foregroundColor(DesignSystem.Colors.textGray)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 16)
                .opacity(store.showWarning ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: store.showWarning)

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

#Preview("Over recommended") {
    let userData = UserPhoneData(
        dailyHours: 6.5,
        addictionLevel: .yes,
        sleepImpact: .almostEveryNight,
        withoutPhoneAnxiety: .veryAnxious,
        idleCheckFrequency: .everyFewMinutes,
        ageGroup: .age25to34
    )

    return AddictionScoreView(
        store: Store(
            initialState: AddictionScoreFeature.State(
                userData: userData,
                userHours: userData.dailyHours,
                userScore: 8.9,
                recommendedHours: 2.0,
                showWarning: true,
                showContinueButton: true
            )
        ) {
            AddictionScoreFeature()
        }
    )
}

#Preview("Edge case: Under recommended") {
    let userData = UserPhoneData(
        dailyHours: 1.75,
        addictionLevel: .sometimes,
        sleepImpact: .rarely,
        withoutPhoneAnxiety: .mostlyFine,
        idleCheckFrequency: .fewTimesDay,
        ageGroup: .age25to34
    )

    return AddictionScoreView(
        store: Store(
            initialState: AddictionScoreFeature.State(
                userData: userData,
                userHours: userData.dailyHours,
                userScore: 1.9,
                recommendedHours: 2.0,
                showWarning: true,
                showContinueButton: true
            )
        ) {
            AddictionScoreFeature()
        }
    )
}
