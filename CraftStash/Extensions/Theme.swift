import SwiftUI

enum Theme {
    static let primaryColor = Color("coral", bundle: nil)
    static let backgroundColor = Color(.systemGroupedBackground)

    static func color(for name: String) -> Color {
        switch name {
        case "coral": return Color(red: 1.0, green: 0.44, blue: 0.37)
        case "ocean": return Color(red: 0.20, green: 0.47, blue: 0.96)
        case "forest": return Color(red: 0.18, green: 0.74, blue: 0.56)
        case "sunshine": return Color(red: 1.0, green: 0.76, blue: 0.03)
        case "lavender": return Color(red: 0.69, green: 0.49, blue: 0.96)
        case "mint": return Color(red: 0.0, green: 0.81, blue: 0.72)
        case "berry": return Color(red: 0.91, green: 0.26, blue: 0.54)
        case "sky": return Color(red: 0.35, green: 0.78, blue: 0.98)
        default: return Color(red: 1.0, green: 0.44, blue: 0.37)
        }
    }

    static let cardCornerRadius: CGFloat = 16
    static let cardShadowRadius: CGFloat = 4
    static let spacing: CGFloat = 16
    static let smallSpacing: CGFloat = 8

    static let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
}
