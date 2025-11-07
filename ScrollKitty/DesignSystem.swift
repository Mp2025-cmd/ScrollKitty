//
//  DesignSystem.swift
//  ScrollKitty
//
//  Design System - Source of truth for all design tokens
//

import SwiftUI

// MARK: - Colors
enum DesignSystem {
    enum Colors {
        // Primary Colors
        static let primaryBlue = Color(hex: "#015AD7")
        static let lightBlue = Color(hex: "#BBDBFF")
        static let brightBlue = Color(hex: "#0191FF")
        
        // Neutral Colors
        static let black = Color.black
        static let white = Color.white
        static let gray = Color(hex: "#D9D9D9")
        static let lightGray = Color(hex: "#AFAFAF")
        static let textGray = Color(hex: "#696969") // dimgrey
        static let darkGray = Color(hex: "#404040")
        
        // Semantic Colors
        static let background = white
        static let splashBackground = primaryBlue
        static let dashboardBackground = Color(hex: "#09121b")
        static let buttonBackground = primaryBlue
        static let buttonTextColor = white
        static let primaryText = black
        static let secondaryText = textGray
        static let selectionBackground = lightBlue
        static let selectionBorder = primaryBlue
        static let progressBarBackground = gray
        static let progressBarFill = primaryBlue
        
        // Timeline Colors
        static let timelineIndicator = brightBlue
        static let timelineLine = lightBlue
        static let timelineSecondaryText = lightGray
        
        // Highlight Colors (for time warnings)
        static let highlightCyan = Color(hex: "#01C9D7")    // Moderate usage
        static let highlightOrange = Color(hex: "#FD4E0F")  // High usage
        static let highlightRed = Color(hex: "#F30000")     // Critical usage
        
        // System Colors
        static let green = Color.green
        static let red = Color.red
    }
    
    // MARK: - Typography
    enum Typography {
        // Font Families
        static let primaryFontFamily = "Sofia Pro"
        static let systemFontFamily = "SF Pro"
        
        // Font Weights
        enum FontWeight {
            case bold
            case medium
            case regular
            case semibold
            
            var swiftUIWeight: Font.Weight {
                switch self {
                case .bold: return .bold
                case .medium: return .medium
                case .regular: return .regular
                case .semibold: return .semibold
                }
            }
        }
        
        // Font Styles
        static func splashTitle() -> Font {
            Font.custom(primaryFontFamily + "-Bold", size: 65)
        }
        
        static func largeTitle() -> Font {
            Font.custom(primaryFontFamily + "-Bold", size: 35)
        }
        
        static func buttonText() -> Font {
            Font.custom(primaryFontFamily + "-Regular", size: 20)
        }
        
        static func subtitle() -> Font {
            Font.custom(primaryFontFamily + "-Medium", size: 16)
        }
        
        static func body() -> Font {
            Font.custom(primaryFontFamily + "-Regular", size: 16)
        }
        
        static func title40() -> Font {
            Font.custom(primaryFontFamily + "-Bold", size: 40)
        }
        
        static func title30() -> Font {
            Font.custom(primaryFontFamily + "-Bold", size: 30)
        }
        
        static func title24() -> Font {
            Font.custom(primaryFontFamily + "-Bold", size: 24)
        }
        
        static func title20() -> Font {
            Font.custom(primaryFontFamily + "-Bold", size: 20)
        }
        
        static func body18() -> Font {
            Font.custom(primaryFontFamily + "-Regular", size: 18)
        }
        
        static func body12() -> Font {
            Font.custom(primaryFontFamily + "-Regular", size: 12)
        }
        
        static func percentage65() -> Font {
            Font.custom(primaryFontFamily + "-Bold", size: 65)
        }
        
        static func percentage25() -> Font {
            Font.custom(primaryFontFamily + "-Bold", size: 25)
        }
        
        static func statusBarTime() -> Font {
            Font.system(size: 17, weight: .semibold)
        }
        
        static func icon18() -> Font {
            Font.system(size: 18)
        }
        
        static func icon24() -> Font {
            Font.system(size: 24)
        }
        
        // Timeline Typography
        static func timelineTime() -> Font {
            Font.custom(primaryFontFamily + "-Medium", size: 12)
        }
        
        static func timelineMessage() -> Font {
            Font.custom(primaryFontFamily + "-Semi_Bold", size: 14)
        }
        
        // Letter Spacing
        static let titleLetterSpacing: CGFloat = -2.0
        static let timelineMessageTracking: CGFloat = -0.3
        
        // Line Height
        static let defaultLineHeight: CGFloat = 22
        static let multilineLineHeight: CGFloat = 35
        static let timelineMessageLineSpacing: CGFloat = 4
    }
    
    // MARK: - Border Radius
    enum BorderRadius {
        static let button: CGFloat = 50
        static let progressBar: CGFloat = 50
        static let selectionOption: CGFloat = 17.5
        static let commitmentBox: CGFloat = 30
        static let barGraph: CGFloat = 8
    }
    
    // MARK: - Border Width
    enum BorderWidth {
        static let selection: CGFloat = 2
    }
    
    // MARK: - Component Sizes
    enum ComponentSize {
        // Buttons
        static let buttonHeight: CGFloat = 56 // Increased from 52
        static let buttonWidth: CGFloat = 327 // Increased from 187 for better touch
        
        // Selection Options
        static let optionHeight: CGFloat = 64
        
        // Progress Bar
        static let progressBarHeight: CGFloat = 5
        static let progressBarWidth: CGFloat = 248
        static let progressSegmentWidth: CGFloat = 30
        
        // Radio Button
        static let radioButtonSize: CGFloat = 13
        
        // Cat Image
        static let catImageWidth: CGFloat = 225
        static let catImageHeight: CGFloat = 204
        
        // Status Bar
        static let statusBarHeight: CGFloat = 62
        
        // Progress Circle
        static let progressCircleSize: CGFloat = 201
        static let progressCircleStrokeWidth: CGFloat = 8
        
        // Bar Graph
        static let barGraphWidth: CGFloat = 67
        static let barGraphHeight: CGFloat = 295
        
        // Icons
        static let checkmarkSize: CGFloat = 18
        static let iconSize24: CGFloat = 24
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Text Style Modifiers
extension View {
    func splashTitleStyle() -> some View {
        self
            .font(DesignSystem.Typography.splashTitle())
            .tracking(DesignSystem.Typography.titleLetterSpacing)
            .foregroundColor(DesignSystem.Colors.white)
    }
    
    func largeTitleStyle() -> some View {
        self
            .font(DesignSystem.Typography.largeTitle())
            .tracking(DesignSystem.Typography.titleLetterSpacing)
            .foregroundColor(DesignSystem.Colors.primaryText)
    }
    
    func buttonTextStyle() -> some View {
        self
            .font(DesignSystem.Typography.buttonText())
            .foregroundColor(DesignSystem.Colors.buttonTextColor)
    }
    
    func subtitleStyle() -> some View {
        self
            .font(DesignSystem.Typography.subtitle())
            .foregroundColor(DesignSystem.Colors.secondaryText)
    }
    
    func bodyStyle() -> some View {
        self
            .font(DesignSystem.Typography.body())
            .foregroundColor(DesignSystem.Colors.primaryText)
    }
}

// MARK: - Component Style Modifiers
extension View {
    func primaryButtonStyle() -> some View {
        self
            .frame(width: DesignSystem.ComponentSize.buttonWidth,
                   height: DesignSystem.ComponentSize.buttonHeight)
            .background(DesignSystem.Colors.black)
            .foregroundColor(DesignSystem.Colors.buttonTextColor)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.button))
            .contentShape(Rectangle()) // Ensures entire frame is tappable
            .padding(.horizontal, 16) // Add horizontal padding for easier tapping
    }
    
    func selectionOptionStyle(isSelected: Bool = false) -> some View {
        self
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.ComponentSize.optionHeight)
            .background(DesignSystem.Colors.selectionBackground)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.selectionOption)
                    .stroke(isSelected ? DesignSystem.Colors.selectionBorder : Color.clear,
                           lineWidth: isSelected ? DesignSystem.BorderWidth.selection : 0)
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.BorderRadius.selectionOption))
            .contentShape(Rectangle())
    }
}
