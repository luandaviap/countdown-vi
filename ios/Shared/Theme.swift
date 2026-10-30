import SwiftUI

/// Design v2 tokens ("sunset and glass", assets/design/DESIGN.md). Single source for colors and
/// geometry; shared by the app and the widget extension.
enum Theme {
    enum Palette {
        static let skyDeep = Color(hex: 0x24104C)
        static let skyMagenta = Color(hex: 0xED286B)
        static let skyOrange = Color(hex: 0xFF8A4C)
        static let neonPink = Color(hex: 0xFF4B9E)
        static let orange = Color(hex: 0xFF814A)
        static let sun = Color(hex: 0xFFE176)
        static let night = Color(hex: 0x100A28)
        static let textPrimary = Color.white
        static let textSecondary = Color(hex: 0xE8BFD7)
        static let progressTrack = Color(hex: 0x80566D)
        static let buttonStart = Color(hex: 0xFF3797)
    }

    enum Glass {
        static let fill = Color.white.opacity(0.12)
        static let border = Color.white.opacity(0.30)
        static let borderWidth: CGFloat = 1
        /// Used instead of the translucent material when Reduce Transparency is on.
        static let solidFill = Palette.night
    }

    enum Metrics {
        static let cardRadius: CGFloat = 16
        static let cardSpacing: CGFloat = 8
        static let sideMargin: CGFloat = 24
        static let sectionSpacing: CGFloat = 28
        static let minButtonHeight: CGFloat = 44
        static let progressHeight: CGFloat = 8
    }

    /// Fallback sky behind the background image.
    static let skyGradient = LinearGradient(
        stops: [
            .init(color: Palette.skyDeep, location: 0),
            .init(color: Palette.skyMagenta, location: 0.55),
            .init(color: Palette.skyOrange, location: 1),
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let buttonGradient = LinearGradient(
        colors: [Palette.buttonStart, Palette.orange],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let progressGradient = LinearGradient(
        colors: [Palette.neonPink, Palette.orange],
        startPoint: .leading,
        endPoint: .trailing
    )
}

extension Color {
    /// 0xRRGGBB literal, as written in DESIGN.md.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
