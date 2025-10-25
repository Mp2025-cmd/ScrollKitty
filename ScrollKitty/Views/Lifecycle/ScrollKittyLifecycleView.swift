import ComposableArchitecture
import SwiftUI

// MARK: - Feature
@Reducer
struct ScrollKittyLifecycleFeature {
    @ObservableState
    struct State: Equatable {
        var currentPage: Int = 0
        var scrollOffset: CGFloat = 0
        var isScrolling: Bool = false
    }
    
    enum Action: Equatable {
        case onAppear
        case pageChanged(Int)
        case scrollOffsetChanged(CGFloat)
        case scrollStarted
        case scrollEnded
        case continueTapped
        case backTapped
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case showNextScreen
            case goBack
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case let .pageChanged(page):
                state.currentPage = page
                return .none
                
            case let .scrollOffsetChanged(offset):
                state.scrollOffset = offset
                return .none
                
            case .scrollStarted:
                state.isScrolling = true
                return .none
                
            case .scrollEnded:
                state.isScrolling = false
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
struct ScrollKittyLifecycleView: View {
    let store: StoreOf<ScrollKittyLifecycleFeature>
    
    private let cardWidth: CGFloat = 201
    private let cardSpacing: CGFloat = 16
    private let totalCards = ScrollKittyState.allStates.count
    
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
                
                // Horizontal Scrollable Cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: cardSpacing) {
                        ForEach(ScrollKittyState.allStates) { state in
                            ScrollKittyCard(
                                state: state,
                                isActive: state.id == store.currentPage
                            )
                            .id(state.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
                .scrollTargetBehavior(.viewAligned)
                .onScrollTargetVisibilityChange(idType: Int.self) { ids in
                    if let firstId = ids.first {
                        store.send(.pageChanged(firstId))
                    }
                }
                .onScrollPhaseChange { oldPhase, newPhase in
                    switch newPhase {
                    case .animating:
                        store.send(.scrollStarted)
                    case .idle:
                        store.send(.scrollEnded)
                    case .interacting:
                        store.send(.scrollStarted)
                    case .tracking:
                        store.send(.scrollStarted)
                    case .decelerating:
                        store.send(.scrollStarted)
                    @unknown default:
                        break
                    }
                }
                
                // Page Control
                PageControl(
                    currentPage: store.currentPage,
                    totalPages: totalCards
                )
                .padding(.top, 8)
                
                // Title
                Text("Lifecycle of Scroll Kitty")
                    .font(.custom("Sofia Pro-Bold", size: 35))
                    .tracking(-2)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                // Subtitle
                VStack(spacing: 0) {
                    Text("Every scroll, swipe, and sleep break changes")
                    Text("Scroll Kitty's state. The more you protect Scroll Kitty,")
                    Text("the healthier Scroll Kitty gets.")
                }
                .font(.custom("Sofia Pro-Regular", size: 16))
                .foregroundColor(DesignSystem.Colors.textGray)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 16)
                
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
    ScrollKittyLifecycleView(
        store: Store(
            initialState: ScrollKittyLifecycleFeature.State(),
            reducer: { ScrollKittyLifecycleFeature() }
        )
    )
}
