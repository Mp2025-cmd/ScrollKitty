import SwiftUI
import ComposableArchitecture
import Foundation

@Reducer
struct ShieldBypassFlowFeature {

    @ObservableState
    struct State: Equatable {
        var catHealth: Int = 100
        let redirectMessage: String

        var stage: Stage = .redirect
        var allowedTimes: [Int] = []
        var selectedMinutes: Int?

        var fullText: String = ""
        var displayedText: String = ""
        var controlsVisible: Bool = false

        init(catHealth: Int = 100, redirectMessage: String) {
            self.catHealth = catHealth
            self.redirectMessage = redirectMessage
        }

        var catState: CatState {
            CatState.from(health: catHealth)
        }
    }

    enum Action: Equatable {
        case onAppear
        case goInAnywayTapped
        case timeSelected(Int)
        case characterTick
        case animationComplete
        case delegate(Delegate)

        enum Delegate: Equatable {
            case dismissAndGrantPass(minutes: Int)
            case dismissWithoutPass
        }
    }

    enum Stage: Equatable {
        case redirect
        case timePrompt
        case acknowledgment
    }

    @Dependency(\.bypassMessageService) var bypassMessageService
    @Dependency(\.continuousClock) var clock
    @Dependency(\.haptics) var haptics

    private enum CancelID {
        static let characterAnimation = "ShieldBypassFlowFeature.characterAnimation"
        static let autoDismiss = "ShieldBypassFlowFeature.autoDismiss"
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.stage = .redirect
                return startAnimation(into: &state, text: state.redirectMessage)

            case .goInAnywayTapped:
                state.stage = .timePrompt
                let allowedTimes = bypassMessageService.getAllowedTimes(for: state.catHealth)
                state.allowedTimes = allowedTimes
                state.selectedMinutes = nil
                return startAnimation(into: &state, text: "How much time do you intent to spend scrolling?")

            case .timeSelected(let minutes):
                state.stage = .acknowledgment
                state.controlsVisible = false
                state.selectedMinutes = minutes
                let message = bypassMessageService.getPainLineMessage(for: state.catHealth, minutes: minutes)
                return startAnimation(into: &state, text: message)

            case .characterTick:
                let currentCharacterIndex = state.displayedText.count
                guard currentCharacterIndex < state.fullText.count else {
                    return .send(.animationComplete)
                }
                
                let nextCharacterIndex = state.fullText.index(state.fullText.startIndex, offsetBy: currentCharacterIndex)
                let nextCharacter = state.fullText[nextCharacterIndex]
                let previousCharacter = state.displayedText.last

                state.displayedText.append(nextCharacter)

                let isLastCharacter = currentCharacterIndex == (state.fullText.count - 1)
                let completedWord = (nextCharacter.isWhitespace && previousCharacter != nil && !(previousCharacter?.isWhitespace ?? true))
                let completedFinalWord = (isLastCharacter && !nextCharacter.isWhitespace)
                let shouldHaptic = completedWord || completedFinalWord

                var effects: [Effect<Action>] = []

                if shouldHaptic {
                    let haptics = self.haptics
                    effects.append(.run { _ in
                        await haptics.wordTick()
                    })
                }

                if state.displayedText.count >= state.fullText.count {
                    effects.append(.send(.animationComplete))
                }

                if effects.isEmpty {
                    return .none
                }
                return .merge(effects)

            case .animationComplete:
                switch state.stage {
                case .redirect, .timePrompt:
                    state.controlsVisible = true
                    return .cancel(id: CancelID.characterAnimation)

                case .acknowledgment:
                    guard let minutes = state.selectedMinutes else {
                        return .send(.delegate(.dismissWithoutPass))
                    }
                    let clock = self.clock
                    return .merge(
                        .cancel(id: CancelID.characterAnimation),
                        .run { send in
                            try await clock.sleep(for: .milliseconds(300))
                            await send(.delegate(.dismissAndGrantPass(minutes: minutes)))
                        }
                        .cancellable(id: CancelID.autoDismiss, cancelInFlight: true)
                    )
                }

            case .delegate:
                return .none
            }
        }
        ._printChanges()
    }

    private func startAnimation(into state: inout State, text: String) -> Effect<Action> {
        state.controlsVisible = false
        state.fullText = text
        state.displayedText = ""

        guard !text.isEmpty else {
            switch state.stage {
            case .redirect, .timePrompt:
                state.controlsVisible = true
                return .merge(
                    .cancel(id: CancelID.characterAnimation),
                    .cancel(id: CancelID.autoDismiss)
                )

            case .acknowledgment:
                // No duplicate logic needed here - .animationComplete will handle the delegate
                state.controlsVisible = true
                return .send(.animationComplete)
            }
        }

        let clock = self.clock
        return .run { [characterCount = text.count] send in
            for _ in 0..<characterCount {
                await send(.characterTick)
                try await clock.sleep(for: .milliseconds(75))
            }
        }
        .cancellable(id: CancelID.characterAnimation, cancelInFlight: true)
    }
}

struct ShieldBypassFlowView: View {
    @Bindable var store: StoreOf<ShieldBypassFlowFeature>

    var body: some View {
        VStack(spacing: -20) {
            store.state.catState.image
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 350)
                .padding(.top, 72)
                .padding(.bottom)

            Text(store.state.displayedText)
                .font(messageFont)
                .tracking(messageTracking)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .top)
                .padding(.horizontal, 40)
                .fixedSize(horizontal: false, vertical: false)

            if store.state.controlsVisible {
                controls
                    .transition(.opacity)
            }

            Spacer(minLength: 0)
        }
        .animation(.easeInOut(duration: 0.25), value: store.state.controlsVisible)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(DesignSystem.Colors.background)
        .onAppear { store.send(.onAppear) }
    }

    private var messageFont: Font {
        .custom("Sofia Pro-Regular", size: 18)
    }

    private var messageTracking: CGFloat {
        0
    }

    @ViewBuilder
    private var controls: some View {
        switch store.state.stage {
        case .redirect:
            HStack(spacing: 12) {
                // Step back - Green (Safe/Positive)
                Button {
                    store.send(.delegate(.dismissWithoutPass))
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Step back")
                            .font(.custom("Sofia Pro-Medium", size: 15))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#34C759"))
                    )
                }
                
                // Go in anyway - Red (Warning/Danger)
                Button {
                    store.send(.goInAnywayTapped)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Go in anyway")
                            .font(.custom("Sofia Pro-Medium", size: 15))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#FF3B30"))
                    )
                }
            }
            .padding(.horizontal, 24)

        case .timePrompt:
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ForEach(store.state.allowedTimes.prefix(2), id: \.self) { minutes in
                        TimeOptionButton(
                            minutes: minutes,
                            isSelected: store.state.selectedMinutes == minutes,
                            onTap: { store.send(.timeSelected(minutes)) }
                        )
                    }
                }
                
                if store.state.allowedTimes.count > 2 {
                    HStack(spacing: 12) {
                        ForEach(store.state.allowedTimes.dropFirst(2), id: \.self) { minutes in
                            TimeOptionButton(
                                minutes: minutes,
                                isSelected: store.state.selectedMinutes == minutes,
                                onTap: { store.send(.timeSelected(minutes)) }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

        case .acknowledgment:
            EmptyView()
        }
    }
}

#Preview("Full Interactive Flow") {
    ShieldBypassFlowView(
        store: Store(
            initialState: ShieldBypassFlowFeature.State(
                catHealth: 85,
                redirectMessage: "Hey. I'm doing alright. Let's not mess up a good streak."
            )
        ) {
            ShieldBypassFlowFeature()
        }
    )
}
