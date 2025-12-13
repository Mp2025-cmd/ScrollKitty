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
        var timeline = TimelineFeature.State()
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case onDisappear
        case appBecameActive
        case loadCatHealth
        case catHealthLoaded(CatHealthData)
        case tabSelected(HomeTab)
        case timeline(TimelineFeature.Action)
    }
    
    @Dependency(\.catHealth) var catHealth
    
    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                print("[HomeFeature] onAppear - loading health (lazy reset if needed)")
                return .send(.loadCatHealth)

            case .onDisappear:
                print("[HomeFeature] onDisappear")
                return .none
                
            case .appBecameActive:
                // Load health first (may trigger lazy midnight reset that clears timeline)
                // Timeline processing happens in catHealthLoaded AFTER reset completes
                print("[HomeFeature] App became active - loading health (lazy reset if needed)")
                return .send(.loadCatHealth)

            case .loadCatHealth:
                // Lazy reset happens automatically inside loadHealth()
                print("[HomeFeature] loadCatHealth")
                state.isLoading = true
                return .run { send in
                    let healthData = await catHealth.loadHealth()
                    print("[HomeFeature] Health loaded: \(healthData.health)% State: \(healthData.catState)")
                    await send(.catHealthLoaded(healthData))
                }

            case .catHealthLoaded(let healthData):
                print("[HomeFeature] catHealthLoaded - Health: \(healthData.health)%")
                state.isLoading = false
                state.catHealth = healthData
                // Sequential to ensure proper dependency chain:
                // 1. Prewarm AI session first
                // 2. Check for welcome message (creates first event if needed)
                // 3. Process raw events (reads timeline after welcome is created)
                // 4. Check for daily summary (after lazy reset and events are processed)
                return .run { send in
                    await send(.timeline(.prewarmAI))
                    await send(.timeline(.checkForWelcomeMessage))
                    await send(.timeline(.processRawEvents))
                    await send(.timeline(.checkForDailySummary))
                }
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            case .timeline:
                return .none
                
            case .binding:
                return .none
            }
        }
        ._printChanges()
        
        Scope(state: \.timeline, action: \.timeline) {
            TimelineFeature()
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
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            // Content based on selected tab
            switch store.selectedTab {
            case .dashboard:
                dashboardContent
            case .timeline:
                TimelineView(store: store.scope(state: \.timeline, action: \.timeline))
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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                store.send(.appBecameActive)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dailySummaryNotificationTapped)) { _ in
            // User tapped 11 PM notification - route through appBecameActive to ensure
            // lazy midnight reset completes BEFORE daily summary is triggered
            print("[HomeView] Received daily summary notification tap - routing through appBecameActive")
            store.send(.appBecameActive)
        }
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
                devices: .all,
                applications: selection.applicationTokens,
                categories: selection.categoryTokens,
                webDomains: []
            )

            // Hidden report that triggers extension
            DeviceActivityReport(.daily, filter: filter)
                .frame(width: 1, height: 1)
                .opacity(0)
                .allowsHitTesting(false)
        }
    }
    
    @State private var showDebugSheet = false
    @State private var debugLogText = ""

    @ViewBuilder
    private var dashboardContent: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Scroll Kitty")
                    .font(.custom("Sofia Pro-Bold", size: 36))
                    .tracking(-1)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                Spacer()

                // Debug export button (dev only)
                #if DEBUG
                Button {
                    Task {
                        debugLogText = await AIDebugLogger.shared.exportLogsAsText()
                        showDebugSheet = true
                    }
                } label: {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                .padding(.trailing, 16)
                #endif
            }
            .padding(.top, 16)
            
            Spacer()
            
            // Cat Image based on health state
            (store.catHealth?.catState ?? .healthy).image
                .resizable()
                .scaledToFit()
                .frame(height: 280)
            
            VStack(spacing: 16) {
                // Health Percentage
                Text("\(store.catHealth?.health ?? 100)%")
                    .font(.custom("Sofia Pro-Bold", size: 50))
                    .tracking(-1)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                // Progress bar with dynamic color based on health
                ProgressBar(
                    percentage: Double(store.catHealth?.health ?? 100),
                    filledColor: healthBarColor(for: store.catHealth?.health ?? 100)
                )
                .frame(width: 256)
                
                // Cat state label
                Text(store.catHealth?.catState.shortName ?? "Healthy")
                    .font(.custom("Sofia Pro-Medium", size: 24))
                    .foregroundColor(store.catHealth?.catState.color ?? .green)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        #if DEBUG
        .sheet(isPresented: $showDebugSheet) {
            NavigationView {
                ScrollView {
                    Text(debugLogText)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .navigationTitle("AI Debug Log")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            showDebugSheet = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ShareLink(item: debugLogText) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
        #endif
    }

    private func healthBarColor(for health: Int) -> Color {
        switch health {
        case 80...100: return Color(hex: "#00c54f") // Green - healthy
        case 60..<80: return Color(hex: "#FFA500")  // Orange - concerned
        case 40..<60: return Color(hex: "#FF6B6B")  // Light red - tired
        case 1..<40: return Color(hex: "#DC143C")   // Crimson - weak
        default: return Color(hex: "#8B0000")       // Dark red - dead
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
