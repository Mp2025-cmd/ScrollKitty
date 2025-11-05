import ComposableArchitecture
import SwiftUI
import UIKit

@Reducer
struct ResultsLoadingFeature {
    @Dependency(\.continuousClock) var clock
    
    @ObservableState
    struct State: Equatable {
        var currentCaptionIndex = 0
        var loadingProgress: Double = 0
        
        let captions = [
            "calculating how cooked your brain is...",
            "checking your dopamine damage...",
            "measuring your scroll addiction...",
            "analyzing your digital detox needs...",
            "computing your phone dependency...",
            "evaluating your screen time chaos...",
            "processing your doomscroll data...",
            "calculating your FOMO levels...",
            "checking if you're terminally online..."
        ]
    }
    
    enum Action: Equatable {
        case onAppear
        case captionTimerTick
        case loadingTimerTick
        case loadingComplete
        case triggerHaptic(Double)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case resultsCalculated
        }
    }
    
    nonisolated struct CancelID: Hashable, Sendable {
        static let captionTimer = Self()
        static let loadingTimer = Self()
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let captionEffect: Effect<Action> = .run { send in
                    for _ in 0..<10 {
                        try await clock.sleep(for: .seconds(1.2))
                        await send(Action.captionTimerTick)
                    }
                }
                .cancellable(id: CancelID.captionTimer)

                // Start loading progress timer (every 0.1s for 10 seconds)
                let loadingEffect: Effect<Action> = .run { send in
                    for _ in 0..<100 {
                        try await clock.sleep(for: .seconds(0.1))
                        await send(Action.loadingTimerTick)
                    }
                    await send(Action.loadingComplete)
                }
                .cancellable(id: CancelID.loadingTimer)

                return .merge(captionEffect, loadingEffect)
                
            case .captionTimerTick:
                state.currentCaptionIndex = (state.currentCaptionIndex + 1) % state.captions.count
                return .none
                
            case .loadingTimerTick:
                state.loadingProgress += 0.01
                let newProgress = state.loadingProgress
                
                // Trigger haptic every 5 percentage points
                if Int(newProgress * 100) % 5 == 0 && newProgress > 0 {
                    return .send(.triggerHaptic(newProgress))
                }
                
                return .none
                
            case .triggerHaptic(let progress):
                return .run { _ in
                    let generator = UIImpactFeedbackGenerator()
                    generator.prepare()
                    
                    // Increase haptic intensity as progress increases
                    let intensity: Double
                    if progress < 0.33 {
                        intensity = 0.3
                    } else if progress < 0.66 {
                        intensity = 0.6
                    } else {
                        intensity = 1.0
                    }
                    
                    generator.impactOccurred(intensity: intensity)
                }
                
            case .loadingComplete:
                return .send(.delegate(.resultsCalculated))
                
            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - View

struct ResultsLoadingView: View {
    let store: StoreOf<ResultsLoadingFeature>
    
    var body: some View {
        ZStack {
            // White background
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Circular Progress Ring (single concentric circle)
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(DesignSystem.Colors.progressBarBackground, lineWidth: 8)
                        .frame(width: 201, height: 201)
                    
                    // Progress circle (partial fill)
                    Circle()
                        .trim(from: 0, to: store.loadingProgress)
                        .stroke(DesignSystem.Colors.progressBarFill, lineWidth: 8)
                        .frame(width: 201, height: 201)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: store.loadingProgress)
                    
                    // Percentage text
                    Text("\(Int(store.loadingProgress * 100))%")
                        .font(.custom("Sofia Pro-Bold", size: 65))
                        .tracking(DesignSystem.Typography.titleLetterSpacing)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }
                
                // Dynamic Caption
                VStack(spacing: 8) {
                    Text("Analyzing...")
                        .font(.custom("Sofia Pro-Bold", size: 35))
                        .tracking(DesignSystem.Typography.titleLetterSpacing)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Text(store.captions[store.currentCaptionIndex])
                        .font(.custom("Sofia Pro-Medium", size: 16))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut(duration: 0.5), value: store.currentCaptionIndex)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    ResultsLoadingView(
        store: Store(
            initialState: ResultsLoadingFeature.State(),
            reducer: { ResultsLoadingFeature() }
        )
    )
}
