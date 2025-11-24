import ComposableArchitecture
import SwiftUI

enum ShieldIntervalOption: String, Equatable, CaseIterable {
    case tenMinutes = "10 minutes"
    case fifteenMinutes = "15 minutes"
    case twentyMinutes = "20 minutes"
    case thirtyMinutes = "30 minutes"
    case fortyFiveMinutes = "45 minutes"
    case sixtyMinutes = "60 minutes"

    var minutes: Int {
        switch self {
        case .tenMinutes: return 10
        case .fifteenMinutes: return 15
        case .twentyMinutes: return 20
        case .thirtyMinutes: return 30
        case .fortyFiveMinutes: return 45
        case .sixtyMinutes: return 60
        }
    }
}

@Reducer
struct ShieldFrequencyFeature {
    @ObservableState
    struct State: Equatable {
        var selectedInterval: ShieldIntervalOption?
    }

    enum Action: Equatable {
        case intervalSelected(ShieldIntervalOption)
        case nextTapped
        case backTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case completeWithSelection(ShieldIntervalOption)
            case goBack
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .intervalSelected(let option):
                state.selectedInterval = option
                return .none

            case .nextTapped:
                if let selectedInterval = state.selectedInterval {
                    return .send(.delegate(.completeWithSelection(selectedInterval)))
                }
                return .none

            case .backTapped:
                return .send(.delegate(.goBack))

            case .delegate:
                return .none
            }
        }
    }
}

struct ShieldFrequencyView: View {
    let store: StoreOf<ShieldFrequencyFeature>

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

                // Title & Subtitle
                VStack(spacing: 12) {
                    Text("How often should Scroll Kitty stop you?")
                        .largeTitleStyle()
                        .multilineTextAlignment(.center)
                    
                    Text("Choose how often the shield appears when opening a distracting app.")
                        .font(.custom("Sofia Pro-Regular", size: 16))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 40)
                .padding(.horizontal, 16)
                .padding(.bottom, 40)

                // Options
                OptionSelector(
                    options: ShieldIntervalOption.allCases,
                    selectedOption: store.selectedInterval,
                    onSelect: { option in
                        store.send(.intervalSelected(option))
                    }
                )
                .padding(.horizontal, 25)

                Spacer()

                // Next Button
                PrimaryButton(title: "Next") {
                    store.send(.nextTapped)
                }
            }
        }
    }
}

#Preview {
    ShieldFrequencyView(
        store: Store(
            initialState: ShieldFrequencyFeature.State(),
            reducer: { ShieldFrequencyFeature() }
        )
    )
}
