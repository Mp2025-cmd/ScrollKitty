//import SwiftUI
//
///// Cartoon-style "OUCH!" impact effect component
///// Displays animated comic book impact with text, cloud burst, and speed lines
//struct OuchImpactView: View {
//    @State private var isAnimating = false
//
//    var body: some View {
//        ZStack {
//            // Speed lines radiating outward
//            ForEach(0..<12) { index in
//                SpeedLine(angle: Double(index) * 30)
//                    .stroke(Color.black.opacity(0.6), lineWidth: 3)
//                    .frame(width: 80, height: 4)
//                    .offset(x: isAnimating ? 60 : 0)
//                    .rotationEffect(.degrees(Double(index) * 30))
//                    .opacity(isAnimating ? 0 : 1)
//            }
//
//            // Starburst background
//            StarBurst(points: 16)
//                .fill(
//                    RadialGradient(
//                        colors: [Color.yellow, Color.orange],
//                        center: .center,
//                        startRadius: 20,
//                        endRadius: 100
//                    )
//                )
//                .frame(width: 200, height: 200)
//                .scaleEffect(isAnimating ? 1.0 : 0.3)
//                .opacity(isAnimating ? 1 : 0)
//
//            // Cloud puff border
//            CloudBurst()
//                .fill(Color.white)
//                .frame(width: 180, height: 180)
//                .scaleEffect(isAnimating ? 1.0 : 0.5)
//                .opacity(isAnimating ? 1 : 0)
//
//            // Halftone dots background (comic book style)
//            Circle()
//                .fill(
//                    RadialGradient(
//                        colors: [Color.black.opacity(0.3), Color.clear],
//                        center: .center,
//                        startRadius: 0,
//                        endRadius: 60
//                    )
//                )
//                .frame(width: 120, height: 120)
//                .blendMode(.multiply)
//                .opacity(isAnimating ? 0.5 : 0)
//
//            // "OUCH!" text
//            ZStack {
//                // Shadow/outline layers
//                Text("OUCH!")
//                    .font(.system(size: 60, weight: .black, design: .rounded))
//                    .foregroundColor(.black)
//                    .offset(x: 3, y: 3)
//
//                // Main text with gradient
//                Text("OUCH!")
//                    .font(.system(size: 60, weight: .black, design: .rounded))
//                    .foregroundStyle(
//                        LinearGradient(
//                            colors: [Color.yellow, Color.orange],
//                            startPoint: .top,
//                            endPoint: .bottom
//                        )
//                    )
//                    .overlay(
//                        Text("OUCH!")
//                            .font(.system(size: 60, weight: .black, design: .rounded))
//                            .foregroundColor(.clear)
//                            .overlay(
//                                LinearGradient(
//                                    colors: [Color.white.opacity(0.8), Color.clear],
//                                    startPoint: .top,
//                                    endPoint: .center
//                                )
//                            )
//                            .mask(
//                                Text("OUCH!")
//                                    .font(.system(size: 60, weight: .black, design: .rounded))
//                            )
//                    )
//            }
//            .scaleEffect(isAnimating ? 1.0 : 0.3)
//            .rotationEffect(.degrees(isAnimating ? 0 : -15))
//            .opacity(isAnimating ? 1 : 0)
//
//            // Small stars around the impact
//            ForEach(0..<5) { index in
//                Star()
//                    .fill(Color.yellow)
//                    .frame(width: 20, height: 20)
//                    .offset(x: cos(Double(index) * 72 * .pi / 180) * 110,
//                           y: sin(Double(index) * 72 * .pi / 180) * 110)
//                    .scaleEffect(isAnimating ? 1.0 : 0)
//                    .opacity(isAnimating ? 1 : 0)
//            }
//        }
//        .frame(width: 250, height: 250)
//        .onAppear {
//            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
//                isAnimating = true
//            }
//        }
//    }
//}
//
//// MARK: - Supporting Shapes
//
///// Starburst shape with pointed rays
//private struct StarBurst: Shape {
//    let points: Int
//
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let outerRadius = min(rect.width, rect.height) / 2
//        let innerRadius = outerRadius * 0.6
//
//        let angleIncrement = (2 * .pi) / Double(points)
//
//        for i in 0..<points {
//            let angle = Double(i) * angleIncrement - .pi / 2
//            let nextAngle = angle + angleIncrement
//
//            // Outer point
//            let outerPoint = CGPoint(
//                x: center.x + cos(angle) * outerRadius,
//                y: center.y + sin(angle) * outerRadius
//            )
//
//            // Inner point (between rays)
//            let innerAngle = angle + angleIncrement / 2
//            let innerPoint = CGPoint(
//                x: center.x + cos(innerAngle) * innerRadius,
//                y: center.y + sin(innerAngle) * innerRadius
//            )
//
//            if i == 0 {
//                path.move(to: outerPoint)
//            } else {
//                path.addLine(to: outerPoint)
//            }
//            path.addLine(to: innerPoint)
//        }
//
//        path.closeSubpath()
//        return path
//    }
//}
//
///// Cloud puff shape for comic book impact borders
//private struct CloudBurst: Shape {
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let radius = min(rect.width, rect.height) / 2
//        let puffCount = 12
//
//        for i in 0..<puffCount {
//            let angle = (Double(i) / Double(puffCount)) * 2 * .pi
//            let puffRadius = radius * (0.85 + 0.15 * sin(Double(i) * 3))
//
//            let x = center.x + cos(angle) * puffRadius
//            let y = center.y + sin(angle) * puffRadius
//
//            if i == 0 {
//                path.move(to: CGPoint(x: x, y: y))
//            }
//
//            let nextAngle = (Double(i + 1) / Double(puffCount)) * 2 * .pi
//            let nextPuffRadius = radius * (0.85 + 0.15 * sin(Double(i + 1) * 3))
//            let nextX = center.x + cos(nextAngle) * nextPuffRadius
//            let nextY = center.y + sin(nextAngle) * nextPuffRadius
//
//            let controlAngle = angle + (.pi / Double(puffCount))
//            let controlRadius = radius * 1.0
//            let controlPoint = CGPoint(
//                x: center.x + cos(controlAngle) * controlRadius,
//                y: center.y + sin(controlAngle) * controlRadius
//            )
//
//            path.addQuadCurve(to: CGPoint(x: nextX, y: nextY), control: controlPoint)
//        }
//
//        path.closeSubpath()
//        return path
//    }
//}
//
///// Speed line shape
//private struct SpeedLine: Shape {
//    let angle: Double
//
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        path.move(to: CGPoint(x: 0, y: rect.midY))
//        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
//        return path
//    }
//}
//
///// Simple star shape
//private struct Star: Shape {
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let outerRadius = min(rect.width, rect.height) / 2
//        let innerRadius = outerRadius * 0.4
//        let points = 5
//
//        for i in 0..<points * 2 {
//            let angle = (Double(i) * .pi / Double(points)) - .pi / 2
//            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
//            let x = center.x + cos(angle) * radius
//            let y = center.y + sin(angle) * radius
//
//            if i == 0 {
//                path.move(to: CGPoint(x: x, y: y))
//            } else {
//                path.addLine(to: CGPoint(x: x, y: y))
//            }
//        }
//
//        path.closeSubpath()
//        return path
//    }
//}
//
//// MARK: - Preview
//
//#Preview("OUCH! Impact") {
//    ZStack {
//        Color.gray.opacity(0.3)
//            .ignoresSafeArea()
//
//        OuchImpactView()
//    }
//}
//
//#Preview("Multiple Impacts") {
//    ZStack {
//        Color.gray.opacity(0.3)
//            .ignoresSafeArea()
//
//        VStack(spacing: 50) {
//            OuchImpactView()
//
//            Text("Tap to see the impact effect")
//                .font(.custom("Sofia Pro-Regular", size: 16))
//                .foregroundColor(.secondary)
//        }
//    }
//}
