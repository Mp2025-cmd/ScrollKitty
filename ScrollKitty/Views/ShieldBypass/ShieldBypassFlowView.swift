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
                return startAnimation(into: &state, text: "How long?")

            case .timeSelected(let minutes):
                state.stage = .acknowledgment
                state.controlsVisible = false
                state.selectedMinutes = minutes
                let message = bypassMessageService.getPainLineMessage(for: state.catHealth, minutes: minutes)
                return startAnimation(into: &state, text: message)

            case .characterTick:
                let currentIndex = state.displayedText.count
                guard currentIndex < state.fullText.count else {
                    return .send(.animationComplete)
                }
                
                let index = state.fullText.index(state.fullText.startIndex, offsetBy: currentIndex)
                state.displayedText.append(state.fullText[index])
                if state.displayedText.count >= state.fullText.count {
                    return .send(.animationComplete)
                }
                return .none

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
                guard let minutes = state.selectedMinutes else {
                    return .send(.delegate(.dismissWithoutPass))
                }
                let clock = self.clock
                return .run { send in
                    try await clock.sleep(for: .milliseconds(300))
                    await send(.delegate(.dismissAndGrantPass(minutes: minutes)))
                }
                .cancellable(id: CancelID.autoDismiss, cancelInFlight: true)
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
        VStack(spacing: 0) {
            
            store.state.catState.image
                .resizable()
                .scaledToFit()
                .frame(width: 280, height: 280)

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
        }
        .animation(.easeInOut(duration: 0.25), value: store.state.controlsVisible)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 300)
        .background(DesignSystem.Colors.background)
        .onAppear { store.send(.onAppear) }
    }

    private var messageFont: Font {
        switch store.state.stage {
        case .timePrompt:
            return .custom("Sofia Pro-Bold", size: 35)
        case .redirect, .acknowledgment:
            return .custom("Sofia Pro-Regular", size: 18)
        }
    }

    private var messageTracking: CGFloat {
        switch store.state.stage {
        case .timePrompt:
            return -2.0
        case .redirect, .acknowledgment:
            return 0
        }
    }

    @ViewBuilder
    private var controls: some View {
        switch store.state.stage {
        case .redirect:
            VStack(spacing: 16) {
                PrimaryButton(title: "Step back") {
                    store.send(.delegate(.dismissWithoutPass))
                }
                
                PrimaryButton(title: "Go in anyway") {
                    store.send(.goInAnywayTapped)
                }
            }
            .padding(.horizontal, 40)

        case .timePrompt:
            VStack(spacing: 16) {
                ForEach(store.state.allowedTimes, id: \.self) { minutes in
                    TimeOptionButton(
                        minutes: minutes,
                        isSelected: store.state.selectedMinutes == minutes,
                        onTap: { store.send(.timeSelected(minutes)) }
                    )
                }
            }
            .padding(.horizontal, 25)

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



private struct TimeOptionButton: View {
    let minutes: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text("\(minutes) minutes")
                    .font(.custom("Sofia Pro-Regular", size: 16))
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .padding(.leading)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? DesignSystem.Colors.primaryBlue : DesignSystem.Colors.textGray)
                    .padding(.trailing)
            }
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.ComponentSize.optionHeight)
            .background(DesignSystem.Colors.selectionBackground)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.selectionOption)
                    .stroke(
                        isSelected ? DesignSystem.Colors.selectionBorder : Color.clear,
                        lineWidth: isSelected ? DesignSystem.BorderWidth.selection : 0
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.selectionOption))
        }
    }
}
