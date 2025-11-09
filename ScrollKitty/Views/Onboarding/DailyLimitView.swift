import ComposableArchitecture
import SwiftUI

enum DailyLimitOption: String, Equatable, CaseIterable {
    case threeHours = "3 hours"
    case fourHours = "4 hours"
    case fiveHours = "5 hours"
    case sixHours = "6 hours"
    case eightHours = "8 hours"

    var minutes: Int {
        switch self {
        case .threeHours: return 180
        case .fourHours: return 240
        case .fiveHours: return 300
        case .sixHours: return 360
        case .eightHours: return 480
        }
    }
}

@Reducer
struct DailyLimitFeature {
    @ObservableState
    struct State: Equatable {
        var selectedLimit: DailyLimitOption?
    }

    enum Action: Equatable {
        case limitSelected(DailyLimitOption)
        case nextTapped
        case backTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case completeWithSelection(DailyLimitOption)
            case goBack
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .limitSelected(let option):
                state.selectedLimit = option
                return .none

            case .nextTapped:
                if let selectedLimit = state.selectedLimit {
                    return .send(.delegate(.completeWithSelection(selectedLimit)))
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

// MARK: - View

struct DailyLimitView: View {
    let store: StoreOf<DailyLimitFeature>

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

                // Title
                Text("Set your daily limit")
                    .largeTitleStyle()
                    .padding(.top, 40)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)

                // Options
                OptionSelector(
                    options: DailyLimitOption.allCases,
                    selectedOption: store.selectedLimit,
                    onSelect: { option in
                        store.send(.limitSelected(option))
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
    DailyLimitView(
        store: Store(
            initialState: DailyLimitFeature.State(),
            reducer: { DailyLimitFeature() }
        )
    )
}

