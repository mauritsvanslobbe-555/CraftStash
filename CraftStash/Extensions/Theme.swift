import SwiftUI

enum Theme {
    // Primary accent — purple
    static let primaryColor = Color(red: 0.42, green: 0.36, blue: 0.91)  // #6C5CE7
    static let accentLight = Color(red: 0.55, green: 0.49, blue: 0.94)   // #8B7CF0

    // Backgrounds (dark)
    static let bg = Color(red: 0.04, green: 0.04, blue: 0.05)            // #0A0A0C
    static let surface1 = Color(red: 0.08, green: 0.08, blue: 0.09)      // #141416
    static let surface2 = Color(red: 0.11, green: 0.11, blue: 0.13)      // #1C1C20
    static let surface3 = Color(red: 0.14, green: 0.14, blue: 0.16)      // #242428
    static let borderColor = Color(red: 0.16, green: 0.16, blue: 0.18)   // #2A2A2E

    // Text
    static let textSecondary = Color(red: 0.56, green: 0.56, blue: 0.58) // #8E8E93
    static let textTertiary = Color(red: 0.35, green: 0.35, blue: 0.37)  // #5A5A5E

    // Status
    static let success = Color(red: 0.20, green: 0.83, blue: 0.60)       // #34D399
    static let danger = Color(red: 1.0, green: 0.42, blue: 0.42)         // #FF6B6B

    // Collection colors
    static func color(for name: String) -> Color {
        switch name {
        case "coral":     return Color(red: 1.0, green: 0.44, blue: 0.37)
        case "ocean":     return Color(red: 0.04, green: 0.52, blue: 0.89)
        case "forest":    return Color(red: 0.0, green: 0.72, blue: 0.58)
        case "sunshine":  return Color(red: 0.99, green: 0.80, blue: 0.43)
        case "lavender":  return Color(red: 0.42, green: 0.36, blue: 0.91)
        case "mint":      return Color(red: 0.20, green: 0.83, blue: 0.60)
        case "berry":     return Color(red: 0.91, green: 0.26, blue: 0.58)
        case "sky":       return Color(red: 0.11, green: 0.63, blue: 0.95)
        default:          return Color(red: 0.42, green: 0.36, blue: 0.91)
        }
    }

    // Platform colors
    static func platformColor(for platform: String) -> Color {
        switch platform.lowercased() {
        case "instagram": return Color(red: 0.88, green: 0.19, blue: 0.42)
        case "tiktok":    return Color(red: 0.0, green: 0.95, blue: 0.92)
        case "youtube":   return .red
        case "pinterest": return Color(red: 0.90, green: 0.0, blue: 0.14)
        case "twitter", "x": return Color(red: 0.11, green: 0.63, blue: 0.95)
        case "screenshot": return success
        default:          return primaryColor
        }
    }

    // Layout
    static let cardCornerRadius: CGFloat = 16
    static let cardCornerRadiusSm: CGFloat = 10
    static let cardShadowRadius: CGFloat = 8
    static let spacing: CGFloat = 16
    static let smallSpacing: CGFloat = 8

    static let gridColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    // Gradient
    static let accentGradient = LinearGradient(
        colors: [Color(red: 0.42, green: 0.36, blue: 0.91), Color(red: 0.66, green: 0.33, blue: 0.97)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
