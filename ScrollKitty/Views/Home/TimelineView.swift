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
                            .fill(Color(hex: "#BBDBFF"))
                            .frame(width: 3)
                            .padding(.leading, 39)
                            .padding(.top, 28)
                        
                        // Timeline items
                        VStack(spacing: 0) {
                            // Date header
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color(hex: "#0191FF"))
                                    .frame(width: 9, height: 9)
                                
                                Text("Jan 1")
                                    .font(.custom("Sofia Pro-Medium", size: 12))
                                    .foregroundColor(.black)
                                    .padding(.horizontal)
                                Text("• Monday")
                                    .font(.custom("Sofia Pro-Medium", size: 12))
                                    .foregroundColor(Color(hex: "#696969"))
                            }
                            .padding(.leading, 33)
                            .padding(.bottom, 30)
                            
                            // Timeline items
                            TimelineItemView(
                                time: "11:00 AM",
                                message: AttributedString("Scrolling away on\nScroll Kitty I see. Don't\nforget about me! 🐱"),
                                catImage: "1_Healthy_Cheerful",
                                backgroundColor: Color(hex: "#015AD7"),
                                timeColor: Color(hex: "#BBDBFF"),
                                iconColor: Color(hex: "#BBDBFF")
                            )
                            
                            TimelineItemView(
                                time: "3:30 PM",
                                message: createInstagramMessage(),
                                catImage: "1_Healthy_Cheerful",
                                backgroundColor: Color(hex: "#015AD7"),
                                timeColor: Color(hex: "#BBDBFF"),
                                iconColor: Color(hex: "#BBDBFF")
                            )
                            
                            TimelineItemView(
                                time: "3:30 PM",
                                message: createTikTokMessage(),
                                catImage: "3_Tired_Low-Energy",
                                backgroundColor: Color(hex: "#003B8E"),
                                timeColor: Color(hex: "#BBDBFF"),
                                iconColor: Color(hex: "#BBDBFF")
                            )
                            
                            TimelineItemView(
                                time: "3:30 PM",
                                message: createInstagramToastMessage(),
                                catImage: "4_Extremely_Sick",
                                backgroundColor: Color(hex: "#00183B"),
                                timeColor: Color(hex: "#BBDBFF"),
                                iconColor: Color(hex: "#BBDBFF")
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
        highlight.foregroundColor = Color(hex: "#01C9D7")
        text.append(highlight)
        text.append(AttributedString(" on\nInstagram today. 😔"))
        return text
    }
    
    private func createTikTokMessage() -> AttributedString {
        var text = AttributedString("Oh no! I'm getting sick.\nYou've been on TikTok for\nover ")
        var highlight = AttributedString("3 hours")
        highlight.foregroundColor = Color(hex: "#FD4E0F")
        text.append(highlight)
        text.append(AttributedString("."))
        return text
    }
    
    private func createInstagramToastMessage() -> AttributedString {
        var text = AttributedString("My paws are toast. I sure\nhope the ")
        var highlight = AttributedString("4 hours ")
        highlight.foregroundColor = Color(hex: "#F30000")
        text.append(highlight)
        text.append(AttributedString("spent on\nInstagram was worth it."))
        return text
    }
}

// MARK: - Timeline Item View
struct TimelineItemView: View {
    let time: String
    let message: AttributedString
    let catImage: String
    let backgroundColor: Color
    let timeColor: Color
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 0) {
            // Timeline icon (cat dashboard icon)
            Image("TabBar_Dashboard")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundColor(iconColor)
                .frame(width: 27, height: 27)
                .background(Color.white)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(hex: "#BBDBFF"), lineWidth: 2)
                )
                .padding(.trailing, 6)
            
            // Card
            ZStack(alignment: .topLeading) {
                backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 21))
                
                HStack(spacing: 0) {
                    // Left side - Text content
                    VStack(alignment: .leading, spacing: 13) {
                        Text(time)
                            .font(.custom("Sofia Pro-Medium", size: 12))
                            .foregroundColor(timeColor)
                        
                        Text(message)
                            .font(.custom("Sofia Pro-Semi_Bold", size: 14))
                            .foregroundColor(.white)
                            .tracking(-0.3)
                            .lineSpacing(4)
                    }
                    .padding(.leading, 13)
                    .padding(.top, 11)
                    .padding(.bottom, 13)
                    
                    Spacer()
                    
                    // Right side - Cat image
                    Image(catImage)
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
