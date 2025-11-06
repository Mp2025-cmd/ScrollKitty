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
                
                // Timeline Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Sample timeline items
                        TimelineItemView(
                            catState: .healthy,
                            timestamp: "Today, 2:45 PM",
                            appName: "Instagram",
                            timeSpent: "45 minutes",
                            catMessage: "You spent a lot of time on Instagram today. Maybe it's time for a break?"
                        )
                        
                        TimelineItemView(
                            catState: .concerned,
                            timestamp: "Today, 12:30 PM",
                            appName: "TikTok",
                            timeSpent: "1 hour 20 minutes",
                            catMessage: "That's quite a bit of scrolling! Your eyes might need rest."
                        )
                        
                        TimelineItemView(
                            catState: .tired,
                            timestamp: "Yesterday, 9:15 PM",
                            appName: "Twitter",
                            timeSpent: "2 hours",
                            catMessage: "You've been online for a long time. Time to rest?"
                        )
                        
                        TimelineItemView(
                            catState: .healthy,
                            timestamp: "Yesterday, 3:00 PM",
                            appName: "LinkedIn",
                            timeSpent: "30 minutes",
                            catMessage: "Good balance today! Keep it up! 😸"
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
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
    
    var body: some View {
        VStack(spacing: 12) {
            // Cat Image and Message
            HStack(spacing: 12) {
                // Cat Image
                Image(catState.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Message Bubble
                VStack(alignment: .leading, spacing: 4) {
                    Text(catMessage)
                        .font(.custom("Sofia Pro-Regular", size: 14))
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .lineLimit(2)
                    
                    Text(timestamp)
                        .font(.custom("Sofia Pro-Regular", size: 12))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
            }
            
            // App Info Card
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(appName)
                        .font(.custom("Sofia Pro-Semi_Bold", size: 16))
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Text(timeSpent)
                        .font(.custom("Sofia Pro-Regular", size: 14))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                // Time Badge
                VStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(catState.color)
                    
                    Text(formatTimeSpent(timeSpent))
                        .font(.custom("Sofia Pro-Semi_Bold", size: 12))
                        .foregroundColor(catState.color)
                }
            }
            .padding(12)
            .background(Color(hex: "#F5F5F5"))
            .cornerRadius(12)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func formatTimeSpent(_ timeSpent: String) -> String {
        // Extract just the duration number
        if timeSpent.contains("hour") {
            return "1h+"
        } else if timeSpent.contains("minute") {
            return "<1h"
        }
        return timeSpent
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

