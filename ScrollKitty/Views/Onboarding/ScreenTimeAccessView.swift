import ComposableArchitecture
import SwiftUI
import FamilyControls
import UserNotifications

// MARK: - Feature
@Reducer
struct ScreenTimeAccessFeature {
    @ObservableState
    struct State: Equatable {
        var isRequestingAccess = false
        var accessGranted = false
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action: Equatable {
        case onAppear
        case requestAccessTapped
        case accessGranted
        case accessDenied
        case dontAllowTapped
        case alert(PresentationAction<Alert>)
        case openSettingsTapped
        case backTapped
        case delegate(Delegate)
        
        enum Alert: Equatable {
            case openSettings
        }
        
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
                
            case .requestAccessTapped:
                state.isRequestingAccess = true
                return .run { send in
                    do {
                        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                        await send(.accessGranted)
                    } catch {
                        await send(.accessDenied)
                    }
                }
                
            case .accessGranted:
                state.isRequestingAccess = false
                state.accessGranted = true
                // Request notification permission silently in background
                return .run { send in
                    let center = UNUserNotificationCenter.current()
                    try? await center.requestAuthorization(options: [.alert, .sound, .badge])
                    await send(.delegate(.showNextScreen))
                }
                
            case .accessDenied:
                state.isRequestingAccess = false
                state.accessGranted = false
                state.alert = AlertState {
                    TextState("Screen Time Access Required")
                } actions: {
                    ButtonState(action: .openSettings) {
                        TextState("Open Settings")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("Scroll Kitty needs Screen Time access to track your usage and keep your cat healthy. Please enable it in Settings to continue.")
                }
                return .none
                
            case .dontAllowTapped:
                state.alert = AlertState {
                    TextState("Screen Time Access Required")
                } actions: {
                    ButtonState(action: .openSettings) {
                        TextState("Open Settings")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("Scroll Kitty needs Screen Time access to track your usage and keep your cat healthy. Please enable it in Settings to continue.")
                }
                return .none
                
            case .alert(.presented(.openSettings)):
                return .run { _ in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        await UIApplication.shared.open(url)
                    }
                }
                
            case .alert:
                return .none
                
            case .openSettingsTapped:
                return .run { _ in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        await UIApplication.shared.open(url)
                    }
                }
                
            case .backTapped:
                return .send(.delegate(.goBack))
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - View
struct ScreenTimeAccessView: View {
    @Bindable var store: StoreOf<ScreenTimeAccessFeature>
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 124)
                
                // Screen Time Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(red: 0.38, green: 0.42, blue: 0.82))
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: "hourglass")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 32)
                
                // Title
                Text("Connect ScrollKitty to\nScreen Time")
                    .font(DesignSystem.Typography.title30())
                    .tracking(DesignSystem.Typography.titleLetterSpacing)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
                
                // Description
                VStack(spacing: 16) {
                    Text("Your data is completely private and never leaves your device.")
                        .font(DesignSystem.Typography.body())
                        .foregroundColor(Color(red: 0.41, green: 0.41, blue: 0.41))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 34)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    // Allow with Face ID button
                    Button(action: {
                        if !store.isRequestingAccess {
                            store.send(.requestAccessTapped)
                        }
                    }) {
                        Text(store.isRequestingAccess ? "Requesting..." : "Allow with Face ID")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color(red: 0.0, green: 0.57, blue: 1.0))
                            .cornerRadius(1000)
                    }
                    .opacity(store.isRequestingAccess ? 0.6 : 1.0)
                    .disabled(store.isRequestingAccess)
                    .padding(.horizontal, 34)
                    
                    // Don't Allow button
                    Button(action: {
                        store.send(.dontAllowTapped)
                    }) {
                        Text("Don't Allow")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Color(red: 0.0, green: 0.57, blue: 1.0))
                    }
                    .padding(.bottom, 8)
                }
                .padding(.bottom, 32)
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    ScreenTimeAccessView(
        store: Store(
            initialState: ScreenTimeAccessFeature.State(),
            reducer: { ScreenTimeAccessFeature() }
        )
    )
}
