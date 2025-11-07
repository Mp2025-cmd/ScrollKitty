import ComposableArchitecture
import SwiftUI
import FamilyControls

// MARK: - Feature
@Reducer
struct ScreenTimeAccessFeature {
    @ObservableState
    struct State: Equatable {
        var isRequestingAccess = false
        var accessGranted = false
    }
    
    enum Action: Equatable {
        case onAppear
        case requestAccessTapped
        case accessGranted
        case accessDenied
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
                return .none
                
            case .accessDenied:
                state.isRequestingAccess = false
                state.accessGranted = false
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
struct ScreenTimeAccessView: View {
    let store: StoreOf<ScreenTimeAccessFeature>
    
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
                Text("Allow access to\nScreen Time")
                    .font(DesignSystem.Typography.title30())
                    .tracking(DesignSystem.Typography.titleLetterSpacing)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
                
                // Description
                VStack(spacing: 16) {
                    Text("Providing \"Scroll Kitty\" access to Screen Time allows it to use you activity data, restrict content and limit the usage of apps and websites")
                        .font(DesignSystem.Typography.body())
                        .foregroundColor(Color(red: 0.41, green: 0.41, blue: 0.41))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    Text("You can control which apps access your own in Screen Time Options in Settings.")
                        .font(DesignSystem.Typography.body())
                        .foregroundColor(Color(red: 0.41, green: 0.41, blue: 0.41))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    Button(action: {
                        // TODO: Open learn more link
                    }) {
                        Text("learn more...")
                            .font(DesignSystem.Typography.body())
                            .foregroundColor(Color(red: 0.0, green: 0.57, blue: 1.0))
                    }
                    .padding(.top, 4)
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
                        store.send(.continueTapped)
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
