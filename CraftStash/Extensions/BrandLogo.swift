import SwiftUI

// MARK: - StuffStash Brand Logo (Logo C "Bookmark")
// Rounded square, warm-to-cool brand gradient, a white S-shaped ribbon,
// and a folded bookmark corner -- per the design handoff's recommended mark.

struct BrandLogo: View {
    var size: CGFloat = 84
    var cornerRadius: CGFloat? = nil

    private var radius: CGFloat {
        cornerRadius ?? size * (22.0 / 84.0)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Theme.brandGradient)

            // White "S" ribbon
            SRibbonShape()
                .stroke(Color.white, style: StrokeStyle(lineWidth: max(1.5, size * (9.0 / 84.0)), lineCap: .round, lineJoin: .round))
                .frame(width: size * 0.5, height: size * 0.58)

            // Bookmark fold -- a small triangular notch in the top-right corner
            BookmarkFoldShape()
                .fill(Color.black.opacity(0.16))
                .frame(width: size * 0.26, height: size * 0.26)
                .position(x: size - size * 0.13, y: size * 0.13)
                .mask(RoundedRectangle(cornerRadius: radius, style: .continuous).frame(width: size, height: size))
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

/// A stylized "S" ribbon, drawn as a smooth double-curve inside a unit box.
private struct SRibbonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let x = rect.minX
        let y = rect.minY

        path.move(to: CGPoint(x: x + w * 0.86, y: y + h * 0.08))
        path.addCurve(
            to: CGPoint(x: x + w * 0.14, y: y + h * 0.34),
            control1: CGPoint(x: x + w * 0.55, y: y - h * 0.02),
            control2: CGPoint(x: x - w * 0.02, y: y + h * 0.14)
        )
        path.addCurve(
            to: CGPoint(x: x + w * 0.86, y: y + h * 0.66),
            control1: CGPoint(x: x + w * 0.32, y: y + h * 0.56),
            control2: CGPoint(x: x + w * 1.02, y: y + h * 0.44)
        )
        path.addCurve(
            to: CGPoint(x: x + w * 0.14, y: y + h * 0.92),
            control1: CGPoint(x: x + w * 0.68, y: y + h * 0.88),
            control2: CGPoint(x: x + w * 0.45, y: y + h * 1.02)
        )
        return path
    }
}

/// A small triangular fold in the top-right corner, for the bookmark detail.
private struct BookmarkFoldShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Wordmark

/// The "stuff·stash" wordmark, with the middot rendered as a small brand-colored dot.
struct BrandWordmark: View {
    var fontSize: CGFloat = 20

    var body: some View {
        HStack(spacing: fontSize * 0.06) {
            Text("stuff")
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.ink)
            Circle()
                .fill(Theme.primary)
                .frame(width: fontSize * 0.18, height: fontSize * 0.18)
            Text("stash")
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.ink)
        }
    }
}

#Preview {
    ZStack {
        Theme.bg.ignoresSafeArea()
        VStack(spacing: 28) {
            BrandLogo(size: 96)
            BrandLogo(size: 44)
            BrandWordmark(fontSize: 24)
        }
    }
}
