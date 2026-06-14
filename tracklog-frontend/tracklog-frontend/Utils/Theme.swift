//  Spotify 스타일 테마

import SwiftUI

struct AppTheme {
    // 배경색
    static let background = Color(hex: "#121212")
    static let secondaryBackground = Color(hex: "#181818")
    static let cardBackground = Color(hex: "#282828")
    
    // 메인 컬러
    static let primary = Color(hex: "#1DB954")  // Spotify Green
    static let primaryDark = Color(hex: "#1AA34A")
    
    // 텍스트
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "#B3B3B3")
    static let textTertiary = Color(hex: "#6A6A6A")
    
    // 액센트
    static let error = Color(hex: "#E22134")
    static let warning = Color(hex: "#FFA500")
    static let info = Color(hex: "#3B82F6")
}

// Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
