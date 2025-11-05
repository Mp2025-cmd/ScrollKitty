import ComposableArchitecture
import SwiftUI

// MARK: - Feature
@Reducer
struct YearsLostFeature {
    @ObservableState
    struct State: Equatable {
        var userData: UserPhoneData?
        var userScore: Double = 0
        var yearsLost: Double = 0
    }

    enum Action: Equatable {
        case onAppear
        case calculateYearsLost(UserPhoneData, userScore: Double)
        case continueTapped
        case backTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case showNextScreen
            case goBack
        }
    }
    // Estimate remaining years of life based on age group
    private func estimateRemainingYears(age: AgeOption) -> Double {
        switch age {
        case .under18: return 70 // Assume avg age 15 → live to 85
        case .age18to24: return 65 // Assume avg age 21 → live to 86
        case .age25to34: return 55 // Assume avg age 30 → live to 85
        case .age35to44: return 45 // Assume avg age 40 → live to 85
        case .age45to54: return 35 // Assume avg age 50 → live to 85
        case .age55plus: return 25 // Assume avg age 60 → live to 85
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case let .calculateYearsLost(userData, userScore):
                state.userData = userData
                state.userScore = userScore

                // Calculate total years that will be lost to screen time
                let dailyHours = userScore
                let yearsRemaining = estimateRemainingYears(age: userData.ageGroup)
                let hoursPerYear = 365.25 * dailyHours
                let totalHoursLost = hoursPerYear * yearsRemaining
                state.yearsLost = totalHoursLost / 8760 // Convert hours to years

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
struct YearsLostView: View {
    let store: StoreOf<YearsLostFeature>
    
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
                
                Spacer()
                
                // Main Message
                VStack(spacing: 0) {
                    Text("At this pace, you'll spend")
                    Text("\(Int(store.yearsLost)) years")
                        .foregroundColor(.red)
                        .font(.custom("Sofia Pro-Bold", size: 40))
                    Text("of your life looking at a screen.")
                    Text("That's decades you")
                    Text("could be living.")
                }
                .font(.custom("Sofia Pro-Bold", size: 30))
                .tracking(DesignSystem.Typography.titleLetterSpacing)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(0)
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Cat Image with Shadow
                ZStack(alignment: .bottom) {
                    VStack {
                        Image("3_Tired_Low-Energy")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 280)
                    }
                    
                    CatShadow(width: 350, height: 5, opacity: 0.65)
                        .offset(y: -20)
                }
                
                Spacer()
                
                // Continue Button
                PrimaryButton(title: "Continue") {
                    store.send(.continueTapped)
                }
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    YearsLostView(
        store: Store(
            initialState: YearsLostFeature.State(),
            reducer: { YearsLostFeature() }
        )
    )
}
