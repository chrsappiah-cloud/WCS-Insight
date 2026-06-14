import SwiftUI

enum MemoryAtlasTheme {
    static let cream = Color(red: 0.97, green: 0.95, blue: 0.90)
    static let card = Color.white
    static let sage = Color(red: 0.42, green: 0.55, blue: 0.42)
    static let sageDark = Color(red: 0.32, green: 0.46, blue: 0.34)
    static let sageLight = Color(red: 0.90, green: 0.94, blue: 0.88)
    static let ink = Color(red: 0.12, green: 0.14, blue: 0.18)
    static let secondaryInk = Color(red: 0.38, green: 0.40, blue: 0.44)
    static let gold = Color(red: 0.72, green: 0.58, blue: 0.28)
    static let hairline = Color.black.opacity(0.08)

    static let pageBackground = LinearGradient(
        colors: [cream, Color(red: 0.99, green: 0.98, blue: 0.95)],
        startPoint: .top,
        endPoint: .bottom
    )
}

enum MemoryAtlasFont {
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .serif)
    }

    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }

    static func label(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
}

struct MemoryAtlasCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(MemoryAtlasTheme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(MemoryAtlasTheme.hairline, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
    }
}

struct MemoryAtlasPrimaryButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(MemoryAtlasFont.label(16))
                if let systemImage {
                    Image(systemName: systemImage)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(MemoryAtlasTheme.sage, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct MemoryAtlasTag: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.medium))
            .foregroundStyle(MemoryAtlasTheme.sageDark)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(MemoryAtlasTheme.sageLight, in: Capsule())
    }
}

struct MemoryAtlasLogoMark: View {
    var size: CGFloat = 34

    var body: some View {
        ZStack {
            Circle()
                .fill(MemoryAtlasTheme.sageLight)
                .frame(width: size, height: size)
            Image(systemName: "location.north.line.fill")
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(MemoryAtlasTheme.sage)
        }
    }
}

struct CaregiverAvatar: View {
    let initials: String

    var body: some View {
        Text(initials)
            .font(.caption.bold())
            .foregroundStyle(MemoryAtlasTheme.sageDark)
            .frame(width: 36, height: 36)
            .background(MemoryAtlasTheme.sageLight, in: Circle())
    }
}
