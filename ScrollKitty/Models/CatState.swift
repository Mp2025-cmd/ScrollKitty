import SwiftUI

public enum CatState: String, Sendable, CaseIterable {
    case healthy = "healthy"
    case concerned = "concerned"
    case tired = "tired"
    case weak = "weak"      // Renamed from "sick" (39-1 HP)
    case dead = "dead"
    
    var displayName: String {
        switch self {
        case .healthy:
            "Healthy & Cheerful"
        case .concerned:
            "Concerned & Anxious"
        case .tired:
            "Tired & Low Energy"
        case .weak:
            "Weak & Struggling"
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
        case .weak:
            "Weak"
        case .dead:
            "Dead"
        }
    }
    
    var image: Image {
        Image(imageName)
    }
    
    var imageName: String {
        switch self {
        case .healthy:
            "1_Healthy_Cheerful"
        case .concerned:
            "2_Concerned_Anxious"
        case .tired:
            "3_Tired_Low-Energy"
        case .weak:
            "4_Extremely_Sick"  // Reuse existing asset
        case .dead:
            "5_Tombstone_Dead"
        }
    }
    
    var color: Color {
        switch self {
        case .healthy:
            Color(hex: "#00c54f")  // Green
        case .concerned:
            Color(hex: "#FFA500")  // Orange
        case .tired:
            Color(hex: "#FF6B6B")  // Light red
        case .weak:
            Color(hex: "#DC143C")  // Crimson
        case .dead:
            Color(hex: "#8B0000")  // Dark red
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .healthy:
            Color(hex: "#015AD7")  // Bright blue
        case .concerned:
            Color(hex: "#015AD7")  // Bright blue
        case .tired:
            Color(hex: "#003B8E")  // Dark blue
        case .weak:
            Color(hex: "#00183B")  // Very dark blue
        case .dead:
            Color(hex: "#000000")  // Black
        }
    }
    
    var timeColor: Color {
        Color(hex: "#BBDBFF")  // Light blue for all states
    }
    
    var iconColor: Color {
        Color(hex: "#BBDBFF")  // Light blue for all states
    }
    
    var healthLevel: HealthLevel {
        switch self {
        case .healthy:
            .excellent
        case .concerned:
            .moderate
        case .tired:
            .poor
        case .weak:
            .critical
        case .dead:
            .dead
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
                "Your cat is weak and struggling."
            case .dead:
                "Your cat has died from excessive screen time."
            }
        }
    }
    
    // MARK: - Health to State Mapping (Single Source of Truth)
    
    /// Maps global health (0-100) to cat state
    /// - 100-80: healthy
    /// - 79-60: concerned
    /// - 59-40: tired
    /// - 39-1: weak
    /// - 0: dead
    nonisolated static func from(health: Int) -> CatState {
        switch health {
        case 80...100:
            return .healthy
        case 60...79:
            return .concerned
        case 40...59:
            return .tired
        case 1...39:
            return .weak
        default:
            return .dead  // 0 or negative
        }
    }
}
