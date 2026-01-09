import SwiftUI

// MARK: - Overlay Color Options
enum OverlayColor: String, CaseIterable {
    case blue = "blue"
    case teal = "teal"
    case green = "green"
    case orange = "orange"
    case pink = "pink"
    case purple = "purple"
    case red = "red"
    case gray = "gray"
    
    var displayName: String {
        switch self {
        case .blue: return "Blue"
        case .teal: return "Teal"
        case .green: return "Green"
        case .orange: return "Orange"
        case .pink: return "Pink"
        case .purple: return "Purple"
        case .red: return "Red"
        case .gray: return "Gray"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .blue: return Color(red: 0.3, green: 0.5, blue: 0.9)
        case .teal: return Color(red: 0.2, green: 0.7, blue: 0.7)
        case .green: return Color(red: 0.3, green: 0.7, blue: 0.4)
        case .orange: return Color(red: 0.95, green: 0.5, blue: 0.2)
        case .pink: return Color(red: 0.9, green: 0.4, blue: 0.6)
        case .purple: return Color(red: 0.6, green: 0.4, blue: 0.9)
        case .red: return Color(red: 0.9, green: 0.3, blue: 0.3)
        case .gray: return Color(red: 0.5, green: 0.5, blue: 0.55)
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .blue: return Color(red: 0.2, green: 0.3, blue: 0.7)
        case .teal: return Color(red: 0.1, green: 0.5, blue: 0.6)
        case .green: return Color(red: 0.2, green: 0.5, blue: 0.3)
        case .orange: return Color(red: 0.8, green: 0.3, blue: 0.1)
        case .pink: return Color(red: 0.7, green: 0.2, blue: 0.5)
        case .purple: return Color(red: 0.4, green: 0.2, blue: 0.7)
        case .red: return Color(red: 0.7, green: 0.15, blue: 0.2)
        case .gray: return Color(red: 0.35, green: 0.35, blue: 0.4)
        }
    }
}

