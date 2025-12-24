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
        var selectedTab: HomeTab = .home
        var catHealth: CatHealthData?
        var isLoading = false
        var timeline = TimelineFeature.State()
        @Presents var bypassFlow: ShieldBypassFlowFeature.State?
        var cachedBypassMessage: String?
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
        case bypassFlow(PresentationAction<ShieldBypassFlowFeature.Action>)
        case showBypassFlow
    }
    
    @Dependency(\.catHealth) var catHealth
    @Dependency(\.notifications) var notifications
    @Dependency(\.screenTimeManager) var screenTimeManager
    @Dependency(\.bypassMessageService) var bypassMessageService

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.loadCatHealth)

                    // Subscribe to bypass notifications
                    await withTaskGroup(of: Void.self) { group in
                        group.addTask {
                            for await _ in self.notifications.bypassNotificationStream() {
                                await send(.showBypassFlow)
                            }
                        }

                        group.addTask {
                            for await _ in self.notifications.dailySummaryNotificationStream() {
                                await send(.appBecameActive)
                            }
                        }
                    }
                }

            case .onDisappear:
                return .none
                
            case .appBecameActive:
                
                return .send(.loadCatHealth)

            case .loadCatHealth:
                // Lazy reset happens automatically inside loadHealth()
                state.isLoading = true
                return .run { send in
                    let healthData = await catHealth.loadHealth()
                    await send(.catHealthLoaded(healthData))
                }

            case .catHealthLoaded(let healthData):
                state.isLoading = false
                state.catHealth = healthData

                return .run { send in
                    await send(.timeline(.checkForWelcomeMessage))
                    await send(.timeline(.processRawEvents))
                    await send(.timeline(.checkForDailySummary))
                }
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            case .timeline:
                return .none

            case .showBypassFlow:
                let currentHealth = state.catHealth?.health ?? 100
                let redirectMessage: String
                if let cached = state.cachedBypassMessage {
                    redirectMessage = cached
                } else {
                    redirectMessage = bypassMessageService.getRedirectMessage(for: currentHealth)
                    state.cachedBypassMessage = redirectMessage
                }
                state.bypassFlow = ShieldBypassFlowFeature.State(catHealth: currentHealth, redirectMessage: redirectMessage)
                return .none

            case .bypassFlow(.presented(.delegate(.dismissAndGrantPass(let minutes)))):
                state.bypassFlow = nil
                state.cachedBypassMessage = nil
                // Update UI immediately (so health changes without needing an app refresh).
                let healthBefore = state.catHealth?.health ?? 100
                let healthAfter = max(0, healthBefore - 5)
                state.catHealth = CatHealthData(
                    health: healthAfter,
                    catState: CatState.from(health: healthAfter),
                    formattedTime: state.catHealth?.formattedTime ?? "0m"
                )

                // Persist immediately so other features (Timeline/TCA deps) that read from UserDefaults
                // don't lag behind and require an app lifecycle refresh.
                let defaults = UserDefaults.appGroup
                defaults.set(healthAfter, forKey: "catHealth")
                defaults.set("normal", forKey: "shieldState")
                defaults.set(minutes, forKey: "selectedBypassMinutes")

                let now = Date()
                defaults.set(defaults.integer(forKey: "bypassCountToday") + 1, forKey: "bypassCountToday")
                defaults.set(defaults.integer(forKey: "totalBypassMinutesToday") + minutes, forKey: "totalBypassMinutesToday")

                if defaults.object(forKey: "firstBypassTimeToday") == nil {
                    defaults.set(now, forKey: "firstBypassTimeToday")
                }
                defaults.set(now, forKey: "lastBypassTimeToday")

                var events: [TimelineEvent] = []
                if let data = defaults.data(forKey: "timelineEvents"),
                   let decoded = try? JSONDecoder().decode([TimelineEvent].self, from: data) {
                    events = decoded
                }

                let event = TimelineEvent(
                    timestamp: now,
                    appName: "App",
                    healthBefore: healthBefore,
                    healthAfter: healthAfter,
                    cooldownStarted: now,
                    eventType: .shieldBypassed
                )
                events.append(event)

                if events.count > 100 {
                    events = Array(events.suffix(100))
                }

                if let encoded = try? JSONEncoder().encode(events) {
                    defaults.set(encoded, forKey: "timelineEvents")
                }

                return .run { _ in
                    await screenTimeManager.removeShieldsAndStartCooldown()
                }

            case .bypassFlow(.presented(.delegate(.dismissWithoutPass))):
                state.bypassFlow = nil
                return .run { _ in
                    if let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app") {
                        defaults.set("normal", forKey: "shieldState")
                    }
                }

            case .bypassFlow(.dismiss):
                state.bypassFlow = nil
                state.cachedBypassMessage = nil
                return .run { _ in
                    if let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app") {
                        defaults.set("normal", forKey: "shieldState")
                    }
                }

            case .bypassFlow:
                return .none

            case .binding:
                return .none

            }
        }
        .ifLet(\.$bypassFlow, action: \.bypassFlow) {
            ShieldBypassFlowFeature()
        }

        Scope(state: \.timeline, action: \.timeline) {
            TimelineFeature()
        }
    }
}

enum HomeTab: Int, Equatable, Sendable {
    case home = 0
    case history = 1
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
            case .home:
                dashboardContent
            case .history:
                TimelineView(store: store.scope(state: \.timeline, action: \.timeline))
            }
            
            VStack {
                Spacer()
                
                // Tab Bar
                HStack(spacing: 0) {
                    // Home Tab
                    Button {
                        store.send(.tabSelected(.home))
                    } label: {
                        VStack(spacing: 8) {
                            Image("TabBar_Dashboard")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(store.selectedTab == .home ? DesignSystem.Colors.primaryBlue : DesignSystem.Colors.secondaryText)

                            Text("Home")
                                .font(.custom("Sofia Pro-Regular", size: 12))
                                .foregroundColor(store.selectedTab == .home ? DesignSystem.Colors.primaryBlue : DesignSystem.Colors.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .opacity(store.selectedTab == .home ? 1 : 0.5)
                    }
                    
                    // History Tab
                    Button {
                        store.send(.tabSelected(.history))
                    } label: {
                        VStack(spacing: 8) {
                            Image("TabBar_Timeline")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(store.selectedTab == .history ? DesignSystem.Colors.primaryBlue : DesignSystem.Colors.secondaryText)

                            Text("History")
                                .font(.custom("Sofia Pro-Regular", size: 12))
                                .foregroundColor(store.selectedTab == .history ? DesignSystem.Colors.primaryBlue : DesignSystem.Colors.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .opacity(store.selectedTab == .history ? 1 : 0.5)
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
        .sheet(item: $store.scope(state: \.bypassFlow, action: \.bypassFlow)) { store in
            ShieldBypassFlowView(store: store)
                .presentationDetents([.large])
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
