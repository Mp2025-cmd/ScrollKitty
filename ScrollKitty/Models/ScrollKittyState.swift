import SwiftUI

// MARK: - Scroll Kitty Health Level
enum ScrollKittyHealthLevel: CaseIterable {
    case healthy
    case slightlySick
    case sick
    case extremelySick
    case dead
    
    var title: String {
        switch self {
        case .healthy:
            return "Healthy"
        case .slightlySick:
            return "Slightly Sick"
        case .sick:
            return "Sick"
        case .extremelySick:
            return "Extremely Sick"
        case .dead:
            return "Dead"
        }
    }
    
    var color: Color {
        switch self {
        case .healthy:
            return Color(red: 0.0, green: 0.77, blue: 0.31) // #00c54f
        case .slightlySick:
            return Color(red: 0.0, green: 0.79, blue: 0.84) // #01c9d7
        case .sick:
            return Color(red: 0.0, green: 0.35, blue: 0.84) // #015ad7
        case .extremelySick:
            return Color(red: 0.99, green: 0.31, blue: 0.06) // #fd4e0f
        case .dead:
            return Color(red: 0.95, green: 0.0, blue: 0.0) // #f30000
        }
    }
    
    var imageName: String {
        switch self {
        case .healthy:
            return "1_Healthy_Cheerful"
        case .slightlySick:
            return "2_Concerned_Anxious"
        case .sick:
            return "3_Tired_Low-Energy"
        case .extremelySick:
            return "4_Extremely_Sick"
        case .dead:
            return "5_Tombstone_Dead"
        }
    }
    
    var description: String {
        switch self {
        case .healthy:
            return "Scroll Kitty is happy and energetic!"
        case .slightlySick:
            return "Scroll Kitty is getting concerned about your usage"
        case .sick:
            return "Scroll Kitty is tired and needs rest"
        case .extremelySick:
            return "Scroll Kitty is very sick from overuse"
        case .dead:
            return "Scroll Kitty has passed away from neglect"
        }
    }
}

// MARK: - Scroll Kitty State Model
struct ScrollKittyState: Identifiable, Equatable {
    let id: Int
    let healthLevel: ScrollKittyHealthLevel
    
    var title: String {
        healthLevel.title
    }
    
    var color: Color {
        healthLevel.color
    }
    
    var imageName: String {
        healthLevel.imageName
    }
    
    var description: String {
        healthLevel.description
    }
}

// MARK: - Sample Data
extension ScrollKittyState {
    static let allStates: [ScrollKittyState] = ScrollKittyHealthLevel.allCases.enumerated().map { index, level in
        ScrollKittyState(id: index, healthLevel: level)
    }
}
