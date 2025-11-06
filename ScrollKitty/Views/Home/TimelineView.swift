import SwiftUI

struct TimelineView: View {
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Timeline")
                        .font(.custom("Sofia Pro-Bold", size: 36))
                        .tracking(-1)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                // Timeline Content - Chat style
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Sample timeline items
                        TimelineItemView(
                            catState: .healthy,
                            timestamp: "2:45 PM",
                            appName: "Instagram",
                            timeSpent: "45 minutes",
                            catMessage: "You spent 45 minutes on Instagram today. Maybe it's time for a break? 🌸",
                            date: "Today"
                        )
                        
                        TimelineItemView(
                            catState: .concerned,
                            timestamp: "12:30 PM",
                            appName: "TikTok",
                            timeSpent: "1 hour 20 minutes",
                            catMessage: "That's quite a bit of scrolling on TikTok! Your eyes might need rest. 👀",
                            date: "Today"
                        )
                        
                        TimelineItemView(
                            catState: .tired,
                            timestamp: "9:15 PM",
                            appName: "Twitter",
                            timeSpent: "2 hours",
                            catMessage: "You've been on Twitter for 2 hours... Time to rest? 😴",
                            date: "Yesterday"
                        )
                        
                        TimelineItemView(
                            catState: .healthy,
                            timestamp: "3:00 PM",
                            appName: "LinkedIn",
                            timeSpent: "30 minutes",
                            catMessage: "Good balance with LinkedIn today! Keep it up! 😸",
                            date: "Yesterday"
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // Space for tab bar
                }
            }
        }
    }
}

// MARK: - Timeline Item View
struct TimelineItemView: View {
    let catState: CatState
    let timestamp: String
    let appName: String
    let timeSpent: String
    let catMessage: String
    let date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date header if needed
            if shouldShowDateHeader() {
                Text(date)
                    .font(.custom("Sofia Pro-Medium", size: 14))
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .padding(.horizontal, 4)
                    .padding(.top, 8)
            }
            
            // Chat bubble style
            HStack(alignment: .bottom, spacing: 8) {
                // Cat Avatar
                Image(catState.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                // Message bubble
                VStack(alignment: .leading, spacing: 0) {
                    // Bubble content
                    VStack(alignment: .leading, spacing: 8) {
                        Text(catMessage)
                            .font(.custom("Sofia Pro-Regular", size: 15))
                            .foregroundColor(DesignSystem.Colors.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // App usage info
                        HStack(spacing: 4) {
                            Image(systemName: "app.fill")
                                .font(.system(size: 11))
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                            
                            Text("\(appName) • \(timeSpent)")
                                .font(.custom("Sofia Pro-Regular", size: 12))
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(chatBubbleBackground)
                    .clipShape(ChatBubbleShape())
                    
                    // Timestamp
                    Text(timestamp)
                        .font(.custom("Sofia Pro-Regular", size: 11))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .padding(.horizontal, 4)
                        .padding(.top, 4)
                }
                
                Spacer()
            }
        }
    }
    
    private var chatBubbleBackground: some View {
        catState.color.opacity(0.1)
    }
    
    private func shouldShowDateHeader() -> Bool {
        // In real app, would check if this is first message of the day
        return true
    }
}

// Chat bubble shape
struct ChatBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 16
        let tailSize: CGFloat = 8
        
        var path = Path()
        
        // Start from top left (with radius)
        path.move(to: CGPoint(x: radius, y: 0))
        
        // Top edge
        path.addLine(to: CGPoint(x: rect.width - radius, y: 0))
        
        // Top right corner
        path.addArc(center: CGPoint(x: rect.width - radius, y: radius),
                    radius: radius,
                    startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)
        
        // Right edge
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - radius))
        
        // Bottom right corner
        path.addArc(center: CGPoint(x: rect.width - radius, y: rect.height - radius),
                    radius: radius,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)
        
        // Bottom edge (with tail)
        path.addLine(to: CGPoint(x: tailSize + radius, y: rect.height))
        
        // Tail
        path.addLine(to: CGPoint(x: tailSize, y: rect.height))
        path.addQuadCurve(to: CGPoint(x: 0, y: rect.height - tailSize),
                          control: CGPoint(x: 0, y: rect.height))
        
        // Left edge
        path.addLine(to: CGPoint(x: 0, y: radius))
        
        // Top left corner
        path.addArc(center: CGPoint(x: radius, y: radius),
                    radius: radius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Cat State Enum
enum CatState {
    case healthy
    case concerned
    case tired
    case sick
    case dead
    
    var imageName: String {
        switch self {
        case .healthy:
            return "1_Healthy_Cheerful"
        case .concerned:
            return "2_Concerned_Anxious"
        case .tired:
            return "3_Tired_Low-Energy"
        case .sick:
            return "4_Extremely_Sick"
        case .dead:
            return "5_Tombstone_Dead"
        }
    }
    
    var color: Color {
        switch self {
        case .healthy:
            return Color(hex: "#00c54f")
        case .concerned:
            return Color(hex: "#FFA500")
        case .tired:
            return Color(hex: "#FF6B6B")
        case .sick:
            return Color(hex: "#DC143C")
        case .dead:
            return Color(hex: "#8B0000")
        }
    }
}

#Preview {
    TimelineView()
}

