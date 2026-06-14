#if canImport(SwiftUI)
import SwiftUI

public enum WCSColor {
    public static let deepNavy = Color(red: 0.05, green: 0.09, blue: 0.14)
    public static let sage = Color(red: 0.42, green: 0.55, blue: 0.45)
    public static let softGold = Color(red: 0.82, green: 0.62, blue: 0.26)
    public static let cream = Color(red: 0.96, green: 0.93, blue: 0.86)
    public static let calmBlue = Color(red: 0.19, green: 0.34, blue: 0.54)
}

public struct WCSCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(18)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(.white.opacity(0.18)))
    }
}

public struct WCSPill: View {
    private let text: String

    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(WCSColor.sage.opacity(0.16), in: Capsule())
            .foregroundStyle(WCSColor.deepNavy)
    }
}
#endif
