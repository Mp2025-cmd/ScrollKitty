import SwiftUI
import ComposableArchitecture
import DeviceActivity
import FamilyControls

// MARK: - DeviceActivityReport Context
extension DeviceActivityReport.Context {
    static let daily = Self("Daily")
}

// MARK: - Domain
@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        var selectedTab: HomeTab = .dashboard
        var catHealth: CatHealthData?
        var isLoading = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case onDisappear
        case loadCatHealth
        case catHealthLoaded(CatHealthData)
        case tabSelected(HomeTab)
        case checkMidnightReset
        case performReset
        case startPolling
        case stopPolling
        case pollingTick
    }
    
    @Dependency(\.userSettings) var userSettings
    @Dependency(\.catHealth) var catHealth
    @Dependency(\.continuousClock) var clock
    
    nonisolated struct CancelID: Hashable, Sendable {
        static let polling = Self()
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                print("[HomeFeature] onAppear")
                return .merge(
                    .send(.checkMidnightReset),
                    .send(.startPolling)
                )

            case .onDisappear:
                print("[HomeFeature] onDisappear")
                return .send(.stopPolling)

            case .checkMidnightReset:
                print("[HomeFeature] checkMidnightReset")
                return .run { send in
                    if await catHealth.shouldResetForNewDay() {
                        print("[HomeFeature] Should reset - sending performReset")
                        await send(.performReset)
                    } else {
                        print("[HomeFeature] No reset needed - loading health")
                        await send(.loadCatHealth)
                    }
                }

            case .performReset:
                print("[HomeFeature] performReset")
                return .run { send in
                    await catHealth.performMidnightReset()
                    await send(.loadCatHealth)
                }

            case .loadCatHealth:
                print("[HomeFeature] loadCatHealth")
                state.isLoading = true
                return .run { send in
                    // Read from App Group UserDefaults (written by extension)
                    let shared = UserDefaults(suiteName: "group.com.scrollkitty.app")
                    let totalSeconds = shared?.double(forKey: "selectedTotalSecondsToday") ?? 0
                    let dailyLimit = await userSettings.loadDailyLimit() ?? 240

                    print("[HomeFeature] Read \(totalSeconds)s (\(Int(totalSeconds/60))m) from selectedTotalSecondsToday (apps only)")
                    
                    // Calculate health using the manager which reads from App Group
                    let healthData = await catHealth.calculateHealth(totalSeconds, dailyLimit)
                    print("[HomeFeature] Health loaded: \(healthData.healthPercentage)% Stage: \(healthData.catStage)")
                    await send(.catHealthLoaded(healthData))
                }

            case .catHealthLoaded(let healthData):
                print("[HomeFeature] catHealthLoaded - Health: \(healthData.healthPercentage)%")
                state.isLoading = false
                state.catHealth = healthData
                return .none
                
            case .startPolling:
                return .run { send in
                    for await _ in await clock.timer(interval: .seconds(30)) {
                        await send(.pollingTick)
                    }
                }
                .cancellable(id: CancelID.polling)
                
            case .stopPolling:
                return .cancel(id: CancelID.polling)
                
            case .pollingTick:
                return .send(.loadCatHealth)
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            case .binding:
                return .none
            }
        }
        ._printChanges()
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

            // Hidden DeviceActivityReport for tracking (apps only, no websites)
            hiddenDeviceActivityReport
        }
        .onAppear { store.send(.onAppear) }
        .onDisappear { store.send(.onDisappear) }
    }

    @ViewBuilder
    private var hiddenDeviceActivityReport: some View {
        // Read selected apps from UserDefaults
        if let shared = UserDefaults(suiteName: "group.com.scrollkitty.app"),
           let selectedAppsData = shared.data(forKey: "selectedApps"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: selectedAppsData) {

            // Create filter for daily usage (apps only, NO websites)
            let filter = DeviceActivityFilter(
                segment: .daily(
                    during: Calendar.current.dateInterval(of: .day, for: Date())!
                ),
                users: .all,
                devices: .all,  // Track on all devices (iPhone/iPad)
                applications: selection.applicationTokens,  // Apps only
                categories: selection.categoryTokens,        // Categories only
                webDomains: []  // EXPLICITLY EMPTY - no website tracking
            )

            // Hidden report that triggers extension
            DeviceActivityReport(.daily, filter: filter)
                .frame(width: 1, height: 1)
                .opacity(0)
                .allowsHitTesting(false)
        }
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
            
            // Cat Image based on real health
            ZStack(alignment: .bottom) {
                VStack {
                    (store.catHealth?.catStage ?? .healthy).image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 280)
                }
                
                CatShadow(width: 250, height: 8, opacity: 0.65)
                    .offset(y: -24)
            }
            
            VStack(spacing: 16) {
                // Health Percentage (real data)
                Text("\(Int(store.catHealth?.healthPercentage ?? 100))%")
                    .font(.custom("Sofia Pro-Bold", size: 50))
                    .tracking(-1)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                // Progress bar with dynamic color based on health
                ProgressBar(
                    percentage: store.catHealth?.healthPercentage ?? 100,
                    filledColor: healthBarColor(for: store.catHealth?.healthPercentage ?? 100)
                )
                .frame(width: 256)
                
                // Screen time display (real data)
                Text(store.catHealth?.formattedTime ?? "0m")
                    .font(.custom("Sofia Pro-Semi_Bold", size: 24))
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
    }
    
    private func healthBarColor(for health: Double) -> Color {
        switch health {
        case 80...100: return Color(hex: "#00c54f") // Green
        case 60..<80: return Color(hex: "#01C9D7")  // Cyan
        case 40..<60: return Color(hex: "#0191FF")  // Blue
        case 20..<40: return Color(hex: "#FD4E0F")  // Orange
        default: return Color(hex: "#F30000")       // Red
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
