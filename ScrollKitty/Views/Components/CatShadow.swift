import SwiftUI

struct CatShadow: View {
    var width: CGFloat = 120
    var height: CGFloat = 20
    var opacity: Double = 0.3
    
    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(opacity),
                        Color.black.opacity(opacity * 0.9),
                        Color.black.opacity(opacity * 0.75),
                        Color.black.opacity(opacity * 0.5),
                        Color.black.opacity(opacity * 0.15)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: width / 2
                )
            )
            .frame(width: width, height: height)
    }
}

#Preview {
    VStack(spacing: 20) {
        VStack(spacing: 0) {
            Image(systemName: "cat.fill")
                .font(.system(size: 60))
            
            CatShadow()
                .padding(.top, -8)
        }
        
        VStack(spacing: 0) {
            Image(systemName: "cat.fill")
                .font(.system(size: 40))
            
            CatShadow(width: 80, height: 15)
                .padding(.top, -6)
        }
    }
    .padding()
    .background(Color(hex: "#f5f5f5"))
}

