import SwiftUI

struct ScrollKittyCard: View {
    let state: ScrollKittyState
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Character Image Container
            ZStack {
                // Background square
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 1.0, green: 0.96, blue: 0.84)) // #fff4d7
                    .frame(width: 201, height: 201)
                
                // Character image
                Image(state.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 180, maxHeight: 180)
            }
            .padding(.bottom, 8)
            
            // Status Label
            HStack(spacing: 8) {
                Image("Ellipse 11")
                    .frame(width: 18, height: 18)
                    .background(state.color)
                    .clipShape(Circle())
                
                Text(state.title)
                    .font(.custom("Sofia Pro-Bold", size: 20))
                    .tracking(-1)
                    .foregroundColor(state.color)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 201)
        .opacity(isActive ? 1.0 : 0.7)
        .scaleEffect(isActive ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            ForEach(ScrollKittyState.allStates) { state in
                ScrollKittyCard(
                    state: state,
                    isActive: state.id == 0
                )
            }
        }
        .padding(.horizontal, 16)
    }
    .background(DesignSystem.Colors.background)
}
