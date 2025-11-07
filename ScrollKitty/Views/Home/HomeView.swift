import SwiftUI
import ComposableArchitecture

// MARK: - Domain
@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        var selectedTab: HomeTab = .dashboard
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case tabSelected(HomeTab)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

enum HomeTab: Int, Equatable, Sendable {
    case dashboard = 0
    case timeline = 1
}

// MARK: - View
struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            // Content based on selected tab
            switch store.selectedTab {
            case .dashboard:
                dashboardContent
            case .timeline:
                TimelineView()
            }
            
            VStack {
                Spacer()
                
                // Tab Bar
                HStack(spacing: 0) {
                    // Dashboard Tab
                    Button {
                        store.send(.tabSelected(.dashboard))
                    } label: {
                        VStack(spacing: 8) {
                            Image("TabBar_Dashboard")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(store.selectedTab == .dashboard ? DesignSystem.Colors.primaryBlue : DesignSystem.Colors.secondaryText)
                            
                            Text("Dashboard")
                                .font(.custom("Sofia Pro-Regular", size: 12))
                                .foregroundColor(store.selectedTab == .dashboard ? DesignSystem.Colors.primaryBlue : DesignSystem.Colors.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .opacity(store.selectedTab == .dashboard ? 1 : 0.5)
                    }
                    
                    // Timeline Tab
                    Button {
                        store.send(.tabSelected(.timeline))
                    } label: {
                        VStack(spacing: 8) {
                            Image("TabBar_Timeline")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(store.selectedTab == .timeline ? DesignSystem.Colors.primaryBlue : DesignSystem.Colors.secondaryText)
                            
                            Text("Timeline")
                                .font(.custom("Sofia Pro-Regular", size: 12))
                                .foregroundColor(store.selectedTab == .timeline ? DesignSystem.Colors.primaryBlue : DesignSystem.Colors.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .opacity(store.selectedTab == .timeline ? 1 : 0.5)
                    }
                }
                .background(DesignSystem.Colors.background)
                .overlay(
                    Divider()
                        .background(Color(hex: "#E8E8E8")),
                    alignment: .top
                )
            }
        }
        .onAppear { store.send(.onAppear) }
    }
    
    @ViewBuilder
    private var dashboardContent: some View {
        VStack(spacing: 0) {
            Text("Scroll Kitty")
                .font(.custom("Sofia Pro-Bold", size: 36))
                .tracking(-1)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .padding(.top, 16)
            
            Spacer()
            
            ZStack(alignment: .bottom) {
                VStack {
                    CatState.healthy.image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 280)
                }
                
                CatShadow(width: 250, height: 5, opacity: 0.65)
                    .offset(y: -24)
            }
            
            VStack(spacing: 16) {
                // Percentage
                Text("36%")
                    .font(.custom("Sofia Pro-Bold", size: 50))
                    .tracking(-1)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                ProgressBar(percentage: 36, filledColor: Color(hex: "#00c54f"))
                    .frame(width: 256)
                
                Text("1 hour 25 minutes")
                    .font(.custom("Sofia Pro-Semi_Bold", size: 24))
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
    }
}

#Preview {
    HomeView(
        store: Store(
            initialState: HomeFeature.State(),
            reducer: { HomeFeature() }
        )
    )
}
