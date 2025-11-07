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
                        .font(.custom("Sofia Pro-Semi_Bold", size: 24))
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                .padding(.horizontal, 34)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                // Timeline Content
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack(alignment: .topLeading) {
                        // Vertical timeline line
                        Rectangle()
                            .fill(DesignSystem.Colors.timelineLine)
                            .frame(width: 3)
                            .padding(.leading, 39)
                            .padding(.top, 28)
                        
                        // Timeline items
                        VStack(spacing: 0) {
                            // Date header
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(DesignSystem.Colors.timelineIndicator)
                                    .frame(width: 10, height: 10)
                                
                                Text("Jan 1")
                                    .font(.custom("Sofia Pro-Semi_Bold", size: 16))
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                
                                Text("• Monday")
                                    .font(.custom("Sofia Pro-Regular", size: 16))
                                    .foregroundColor(DesignSystem.Colors.timelineSecondaryText)
                                Spacer()
                            }
                            .padding(.leading, 35)
                            .padding(.bottom, 20)
                            
                            // Timeline items
                            TimelineItemView(
                                time: "11:00 AM",
                                message: AttributedString("Scrolling away on\nScroll Kitty I see. Don't\nforget about me! 🐱"),
                                catState: .healthy
                            )
                            
                            TimelineItemView(
                                time: "3:30 PM",
                                message: createInstagramMessage(),
                                catState: .healthy
                            )
                            
                            TimelineItemView(
                                time: "3:30 PM",
                                message: createTikTokMessage(),
                                catState: .tired
                            )
                            
                            TimelineItemView(
                                time: "3:30 PM",
                                message: createInstagramToastMessage(),
                                catState: .sick
                            )
                        }
                    }
                    .padding(.bottom, 100) // Space for tab bar
                }
            }
        }
    }
    
    private func createInstagramMessage() -> AttributedString {
        var text = AttributedString("Yikes! You have spent\n")
        var highlight = AttributedString("2 hours and 14 minutes")
        highlight.foregroundColor = DesignSystem.Colors.highlightCyan
        text.append(highlight)
        text.append(AttributedString(" on\nInstagram today. 😔"))
        return text
    }
    
    private func createTikTokMessage() -> AttributedString {
        var text = AttributedString("Oh no! I'm getting sick.\nYou've been on TikTok for\nover ")
        var highlight = AttributedString("3 hours")
        highlight.foregroundColor = DesignSystem.Colors.highlightOrange
        text.append(highlight)
        text.append(AttributedString("."))
        return text
    }
    
    private func createInstagramToastMessage() -> AttributedString {
        var text = AttributedString("My paws are toast. I sure\nhope the ")
        var highlight = AttributedString("4 hours ")
        highlight.foregroundColor = DesignSystem.Colors.highlightRed
        text.append(highlight)
        text.append(AttributedString("spent on\nInstagram was worth it."))
        return text
    }
}

// MARK: - Timeline Item View
struct TimelineItemView: View {
    let time: String
    let message: AttributedString
    let catState: CatState
    
    var body: some View {
        HStack(spacing: 0) {
            // Timeline icon (cat dashboard icon)
            Image("TabBar_Dashboard")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundColor(catState.iconColor)
                .frame(width: 27, height: 27)
                .background(DesignSystem.Colors.white)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(DesignSystem.Colors.timelineLine, lineWidth: 2)
                )
                .padding(.trailing, 6)
            
            // Card
            ZStack(alignment: .topLeading) {
                catState.backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 21))
                
                HStack(spacing: 0) {
                    // Left side - Text content
                    VStack(alignment: .leading, spacing: 13) {
                        Text(time)
                            .font(DesignSystem.Typography.timelineTime())
                            .foregroundColor(catState.timeColor)
                        
                        Text(message)
                            .font(DesignSystem.Typography.timelineMessage())
                            .foregroundColor(DesignSystem.Colors.white)
                            .tracking(DesignSystem.Typography.timelineMessageTracking)
                            .lineSpacing(DesignSystem.Typography.timelineMessageLineSpacing)
                    }
                    .padding(.leading, 13)
                    .padding(.top, 11)
                    .padding(.bottom, 13)
                    
                    Spacer()
                    
                    // Right side - Cat image
                    catState.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 133, height: 120)
                        .offset(y: 5)
                }
            }
            .frame(width: 310, height: 129)
            
            Spacer()
        }
        .padding(.leading, 27)
        .padding(.bottom, 15)
    }
}

#Preview {
    TimelineView()
}
