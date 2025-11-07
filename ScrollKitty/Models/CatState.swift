import SwiftUI

public enum CatState: String, Sendable, CaseIterable {
    case healthy = "healthy"
    case concerned = "concerned"
    case tired = "tired"
    case sick = "sick"
    case dead = "dead"
    
    var displayName: String {
        switch self {
        case .healthy:
            "Healthy & Cheerful"
        case .concerned:
            "Concerned & Anxious"
        case .tired:
            "Tired & Low Energy"
        case .sick:
            "Extremely Sick"
        case .dead:
            "Dead"
        }
    }
    
    var shortName: String {
        switch self {
        case .healthy:
            "Healthy"
        case .concerned:
            "Concerned"
        case .tired:
            "Tired"
        case .sick:
            "Sick"
        case .dead:
            "Dead"
        }
    }
    
    var image: Image {
        switch self {
        case .healthy:
            return Image("1_Healthy_Cheerful")
        case .concerned:
            return Image("2_Concerned_Anxious")
        case .tired:
            return Image("3_Tired_Low-Energy")
        case .sick:
            return Image("4_Extremely_Sick")
        case .dead:
            return Image("5_Tombstone_Dead")
        }
    }
    
    var imageName: String {
        switch self {
        case .healthy:
            "1_Healthy_Cheerful"
        case .concerned:
            "2_Concerned_Anxious"
        case .tired:
            "3_Tired_Low-Energy"
        case .sick:
            "4_Extremely_Sick"
        case .dead:
            "5_Tombstone_Dead"
        }
    }
    
    var color: Color {
        switch self {
        case .healthy:
            return Color(hex: "#00c54f") // Green
        case .concerned:
            return Color(hex: "#FFA500") // Orange
        case .tired:
            return Color(hex: "#FF6B6B") // Red
        case .sick:
            return Color(hex: "#DC143C") // Crimson
        case .dead:
            return Color(hex: "#8B0000") // Dark red
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .healthy:
            return Color(hex: "#015AD7") // Bright blue
        case .concerned:
            return Color(hex: "#015AD7") // Bright blue
        case .tired:
            return Color(hex: "#003B8E") // Dark blue
        case .sick:
            return Color(hex: "#00183B") // Very dark blue
        case .dead:
            return Color(hex: "#000000") // Black
        }
    }
    
    var timeColor: Color {
        return Color(hex: "#BBDBFF") // Light blue for all states
    }
    
    var iconColor: Color {
        return Color(hex: "#BBDBFF") // Light blue for all states
    }
    
    var healthLevel: HealthLevel {
        switch self {
        case .healthy:
            return .excellent
        case .concerned:
            return .moderate
        case .tired:
            return .poor
        case .sick:
            return .critical
        case .dead:
            return .dead
        }
    }
    
    public enum HealthLevel: String, Sendable, CaseIterable {
        case excellent = "Excellent"
        case moderate = "Moderate"
        case poor = "Poor"
        case critical = "Critical"
        case dead = "Dead"
        
        var description: String {
            switch self {
            case .excellent:
                "Your cat is healthy and happy! Keep up the good work."
            case .moderate:
                "Your cat is starting to feel the effects of screen time."
            case .poor:
                "Your cat is tired and needs rest."
            case .critical:
                "Your cat is extremely sick from too much screen time."
            case .dead:
                "Your cat has died from excessive screen time."
            }
        }
    }
    
    // Get cat state based on screen time hours
    static func from(screenTimeHours: Double) -> CatState {
        switch screenTimeHours {
        case 0..<2:
            return .healthy
        case 2..<4:
            return .concerned
        case 4..<6:
            return .tired
        case 6..<8:
            return .sick
        default:
            return .dead
        }
    }
    
    // Get cat state based on percentage (0-100)
    static func from(percentage: Int) -> CatState {
        switch percentage {
        case 0..<20:
            return .healthy
        case 20..<40:
            return .concerned
        case 40..<60:
            return .tired
        case 60..<80:
            return .sick
        default:
            return .dead
        }
    }
}

