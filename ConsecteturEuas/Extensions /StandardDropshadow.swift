import Foundation
import SwiftUI

// MARK: - Color Extension for Hex Support

    extension Color {
        init?(hex: String) {
            let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int: UInt64 = 0

            guard Scanner(string: hex).scanHexInt64(&int) else {
                return nil
            }

            let a, r, g, b: UInt64

            switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (
                    255,
                    (int >> 8) * 17,
                    (int >> 4 & 0xF) * 17,
                    (int & 0xF) * 17
                )
            case 6: // RGB (24-bit)
                (a, r, g, b) = (
                    255,
                    int >> 16 & 0xFF,
                    int >> 8 & 0xFF,
                    int & 0xFF
                )
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (
                    int >> 24 & 0xFF,
                    int >> 16 & 0xFF,
                    int >> 8 & 0xFF,
                    int & 0xFF
                )
            default:
                return nil // Invalid hex length
            }

            self.init(
                .sRGB,
                red: Double(r) / 255,
                green: Double(g) / 255,
                blue: Double(b) / 255,
                opacity: Double(a) / 255
            )
        }

    
    func toHex(includeAlpha: Bool = false) -> String? {
            // Convert SwiftUI Color to UIColor
            let uiColor = UIColor(self)
            
            // Extract RGBA components
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
                return nil
            }
            
            // Convert to 0-255 range
            let r = Int(red * 255)
            let g = Int(green * 255)
            let b = Int(blue * 255)
            let a = Int(alpha * 255)
            
            if includeAlpha {
                return String(format: "%02X%02X%02X%02X", r, g, b, a)
            } else {
                return String(format: "%02X%02X%02X", r, g, b)
            }
        }
}

// MARK: - Fixed StandardDropshadow ViewModifier
struct StandardDropshadow: ViewModifier {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    // Default initializer with proper shadow color
    init(color: Color = Color(hex: "262626").opacity(0.3) as! Color, radius: CGFloat = 5, x: CGFloat = 0, y: CGFloat = 2) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }

    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius, x: x, y: y)
    }
}

// MARK: - View Extension
extension View {
    func standardDropshadow(color: Color = Color(hex: "262626").opacity(0.3) as! Color, radius: CGFloat = 5, x: CGFloat = 0, y: CGFloat = 2) -> some View {
        self.modifier(StandardDropshadow(color: color, radius: radius, x: x, y: y))
    }
}

// MARK: - Alternative: Multiple Shadow Layers for Depth
extension View {
    func layeredDropshadow() -> some View {
        self
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}
