import SwiftUI

// MARK: - StuffStash Design Tokens
// Based on the design handoff: dark purple-warm base, vivid platform accents.

enum Theme {
    // MARK: - Surfaces (Dark mode)
    static let bg        = Color(hex: 0x0A0810)  // app background -- near-black with violet undertone
    static let bgGlow    = Color(hex: 0x120F1C)  // subtle gradient companion
    static let surface   = Color(hex: 0x16121F)  // cards on bg
    static let surfaceHi = Color(hex: 0x1F1A2C)  // elevated cards, sheets
    static let surfaceLo = Color(hex: 0x0F0C17)  // recessed

    static let border    = Color.white.opacity(0.07)
    static let borderHi  = Color.white.opacity(0.12)

    // MARK: - Text / Ink
    static let ink       = Color(hex: 0xF4F1FA)           // primary text
    static let inkMute   = Color(hex: 0xF4F1FA).opacity(0.62) // secondary
    static let inkDim    = Color(hex: 0xF4F1FA).opacity(0.38) // tertiary / labels
    static let inkFaint  = Color(hex: 0xF4F1FA).opacity(0.18) // quaternary / dividers

    // MARK: - Brand
    static let primary     = Color(hex: 0x7B5CFF) // signature purple
    static let primarySoft = Color(hex: 0x9D85FF) // hover / soft accent
    static let primaryDeep = Color(hex: 0x5A3FE5) // pressed
    static let primaryTint = Color(hex: 0x7B5CFF).opacity(0.16) // background tint

    // MARK: - Functional Accents
    static let warm     = Color(hex: 0xFFB75A) // tips, callouts, sunshine
    static let warmDeep = Color(hex: 0xE89530)
    static let mint     = Color(hex: 0x4FE3B0) // success, "new"
    static let rose     = Color(hex: 0xFF6B9D) // favorite
    static let coral    = Color(hex: 0xFF7A5A) // delete, danger-soft

    // MARK: - Platform Palette
    static let igPink   = Color(hex: 0xFF3D5C)
    static let igPurple = Color(hex: 0xC13EE0)
    static let igOrange = Color(hex: 0xFFA239)
    static let ttCyan   = Color(hex: 0x25F4EE)
    static let ttRed    = Color(hex: 0xFE2C55)
    static let ytRed    = Color(hex: 0xFF3D3D)
    static let pinRed   = Color(hex: 0xE60023)
    static let xBlue    = Color(hex: 0x1DA1F2)

    // MARK: - Legacy Aliases (backwards compat)
    static let primaryColor   = primary
    static let accentLight    = primarySoft
    static let surface1       = surface
    static let surface2       = surfaceHi
    static let surface3       = surfaceHi
    static let textSecondary  = inkMute
    static let textTertiary   = inkDim
    static let success        = mint
    static let danger         = coral
    static let borderColor    = border

    // MARK: - Platform Colors
    static func platformColor(for platform: String) -> Color {
        switch platform.lowercased() {
        case "instagram": return igPink
        case "tiktok":    return ttCyan
        case "youtube":   return ytRed
        case "pinterest": return pinRed
        case "twitter", "x": return xBlue
        case "facebook":  return Color(hex: 0x1877F2)
        case "vimeo":     return Color(hex: 0x1AB7EA)
        case "reddit":    return Color(hex: 0xFF4500)
        case "tumblr":    return Color(hex: 0x35465C)
        case "screenshot": return mint
        default:          return primary
        }
    }

    // MARK: - Platform Gradients
    static func platformGradient(for platform: String) -> LinearGradient {
        switch platform.lowercased() {
        case "instagram":
            return LinearGradient(colors: [igOrange, igPink, igPurple], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "tiktok":
            return LinearGradient(colors: [.black, Color(hex: 0x1a1a1a), ttRed], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "youtube":
            return LinearGradient(colors: [Color(hex: 0x2a0000), ytRed], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "pinterest":
            return LinearGradient(colors: [Color(hex: 0x4a0008), pinRed], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "twitter", "x":
            return LinearGradient(colors: [Color(hex: 0x001a2e), xBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [primary.opacity(0.8), primary.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    // MARK: - Collection Colors
    static func color(for name: String) -> Color {
        switch name {
        case "coral":     return coral
        case "ocean":     return Color(hex: 0x0D85E3)
        case "forest":    return Color(hex: 0x00B894)
        case "sunshine":  return warm
        case "lavender":  return primary
        case "mint":      return mint
        case "berry":     return rose
        case "sky":       return xBlue
        default:          return primary
        }
    }

    // MARK: - Gradients
    static let accentGradient = LinearGradient(
        colors: [primary, primarySoft, rose],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let warmGradient = LinearGradient(
        colors: [warmDeep, rose],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroGradient = LinearGradient(
        colors: [primary, Color(hex: 0xB57AFF), rose],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let brandGradient = LinearGradient(
        colors: [warm, rose, primary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Layout
    static let cardRadius: CGFloat = 16
    static let cardRadiusSm: CGFloat = 12
    static let cardRadiusLg: CGFloat = 22
    static let sheetRadius: CGFloat = 28
    static let chipRadius: CGFloat = 17
    static let pillRadius: CGFloat = 999

    // Legacy
    static let cardCornerRadius: CGFloat = 16
    static let cardCornerRadiusSm: CGFloat = 12
    static let cardShadowRadius: CGFloat = 8
    static let spacing: CGFloat = 16
    static let smallSpacing: CGFloat = 8

    static let gridColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
}

// MARK: - Color Hex Initializer
extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
