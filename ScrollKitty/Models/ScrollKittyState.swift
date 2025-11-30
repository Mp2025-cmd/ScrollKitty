import SwiftUI

// MARK: - Scroll Kitty State Model
struct ScrollKittyState: Identifiable, Equatable {
    let id: Int
    let catState: CatState
    
    var title: String {
        catState.shortName
    }
    
    var color: Color {
        catState.color
    }
    
    var imageName: String {
        catState.imageName
    }
    
    var description: String {
        switch catState {
        case .healthy:
            return "Scroll Kitty is happy and energetic!"
        case .concerned:
            return "Scroll Kitty is getting concerned about your usage"
        case .tired:
            return "Scroll Kitty is tired and needs rest"
        case .weak:
            return "Scroll Kitty is weak and struggling"
        case .dead:
            return "Scroll Kitty has passed away from neglect"
        }
    }
}

// MARK: - Sample Data
extension ScrollKittyState {
    static let allStates: [ScrollKittyState] = CatState.allCases.enumerated().map { index, catState in
        ScrollKittyState(id: index, catState: catState)
    }
}
