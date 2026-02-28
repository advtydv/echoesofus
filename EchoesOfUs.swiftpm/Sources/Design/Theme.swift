import SwiftUI

enum EchoTheme {
    static let sand = Color(red: 0.95, green: 0.90, blue: 0.82)
    static let dawn = Color(red: 0.98, green: 0.84, blue: 0.69)
    static let clay = Color(red: 0.76, green: 0.46, blue: 0.29)
    static let clayDark = Color(red: 0.60, green: 0.34, blue: 0.22)
    static let night = Color(red: 0.10, green: 0.14, blue: 0.20)
    static let moss = Color(red: 0.34, green: 0.51, blue: 0.39)
    static let sky = Color(red: 0.77, green: 0.88, blue: 0.95)
    static let cream = Color(red: 0.99, green: 0.97, blue: 0.93)

    static let background = LinearGradient(
        colors: [dawn, sand, sky],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let strongBackground = LinearGradient(
        colors: [night, night.opacity(0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct EchoPalette {
    let highContrast: Bool

    var backdropText: Color {
        highContrast ? .white : EchoTheme.night
    }

    var backdropSubtext: Color {
        highContrast ? Color.white.opacity(0.9) : EchoTheme.night.opacity(0.82)
    }

    var cardBackground: Color {
        highContrast ? Color.black.opacity(0.84) : EchoTheme.cream.opacity(0.84)
    }

    var cardBorder: Color {
        highContrast ? Color.white.opacity(0.95) : Color.white.opacity(0.58)
    }

    var cardText: Color {
        highContrast ? .white : EchoTheme.night
    }

    var cardSubtext: Color {
        highContrast ? Color.white.opacity(0.88) : EchoTheme.night.opacity(0.78)
    }

    var badgeBackground: Color {
        highContrast ? Color.white.opacity(0.16) : Color.white.opacity(0.68)
    }

    var badgeText: Color {
        highContrast ? .white : EchoTheme.night
    }

    var badgeIcon: Color {
        highContrast ? .white : EchoTheme.clay
    }

    var warningBackground: Color {
        highContrast ? EchoTheme.clayDark : Color.white.opacity(0.72)
    }

    var warningText: Color {
        highContrast ? .white : EchoTheme.night
    }
}

extension LearnerProfile {
    var palette: EchoPalette { EchoPalette(highContrast: highContrast) }
}

struct EchoBackdrop: View {
    let highContrast: Bool
    let focusMode: Bool
    @State private var drift = false

    var body: some View {
        ZStack {
            (highContrast ? EchoTheme.strongBackground : EchoTheme.background)
                .ignoresSafeArea()

            if !highContrast {
                Circle()
                    .fill(EchoTheme.clay.opacity(0.20))
                    .frame(width: 280, height: 280)
                    .blur(radius: 20)
                    .offset(x: drift ? -120 : -80, y: drift ? -220 : -180)

                Circle()
                    .fill(EchoTheme.moss.opacity(0.18))
                    .frame(width: 240, height: 240)
                    .blur(radius: 18)
                    .offset(x: drift ? 130 : 90, y: drift ? 260 : 210)

                RoundedRectangle(cornerRadius: 60, style: .continuous)
                    .fill(EchoTheme.sky.opacity(0.24))
                    .frame(width: 360, height: 160)
                    .blur(radius: 24)
                    .rotationEffect(.degrees(-14))
                    .offset(x: drift ? 110 : 70, y: drift ? -70 : -30)
            }
        }
        .onAppear {
            guard !focusMode else { return }
            withAnimation(.easeInOut(duration: 14).repeatForever(autoreverses: true)) {
                drift.toggle()
            }
        }
    }
}

struct EchoCardModifier: ViewModifier {
    let highContrast: Bool

    func body(content: Content) -> some View {
        let palette = EchoPalette(highContrast: highContrast)

        content
            .padding(16)
            .background(palette.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(palette.cardBorder, lineWidth: highContrast ? 2 : 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(highContrast ? 0.06 : 0.24),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .allowsHitTesting(false)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.black.opacity(highContrast ? 0.30 : 0.12), radius: 16, x: 0, y: 10)
    }
}

extension View {
    func echoCard(highContrast: Bool) -> some View {
        modifier(EchoCardModifier(highContrast: highContrast))
    }

    @ViewBuilder
    func readableText(_ enabled: Bool) -> some View {
        if enabled {
            self.fontDesign(.rounded).lineSpacing(4)
        } else {
            self
        }
    }

    func staggeredEntrance(index: Int, focusMode: Bool) -> some View {
        modifier(StaggeredEntrance(index: index, focusMode: focusMode))
    }
}

struct PrimaryActionButton: ButtonStyle {
    let highContrast: Bool

    func makeBody(configuration: Configuration) -> some View {
        PrimaryButtonBody(configuration: configuration, highContrast: highContrast)
    }
}

private struct PrimaryButtonBody: View {
    @Environment(\.isEnabled) private var isEnabled
    let configuration: PrimaryActionButton.Configuration
    let highContrast: Bool

    var body: some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(highContrast ? EchoTheme.night : Color.white)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: highContrast
                                ? [Color.white, Color.white.opacity(0.88)]
                                : [EchoTheme.clay, EchoTheme.clayDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .opacity(isEnabled ? 1 : 0.5)
            .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryActionButton: ButtonStyle {
    let highContrast: Bool

    func makeBody(configuration: Configuration) -> some View {
        SecondaryButtonBody(configuration: configuration, highContrast: highContrast)
    }
}

private struct SecondaryButtonBody: View {
    @Environment(\.isEnabled) private var isEnabled
    let configuration: SecondaryActionButton.Configuration
    let highContrast: Bool

    var body: some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(highContrast ? Color.white : EchoTheme.night)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(highContrast ? Color.black.opacity(0.64) : Color.white.opacity(0.82))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(highContrast ? Color.white.opacity(0.9) : Color.white.opacity(0.58), lineWidth: 1)
            )
            .opacity(isEnabled ? 1 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct OptionChipStyle: ButtonStyle {
    let isSelected: Bool
    let highContrast: Bool

    func makeBody(configuration: Configuration) -> some View {
        OptionChipBody(configuration: configuration, isSelected: isSelected, highContrast: highContrast)
    }
}

private struct OptionChipBody: View {
    @Environment(\.isEnabled) private var isEnabled
    let configuration: OptionChipStyle.Configuration
    let isSelected: Bool
    let highContrast: Bool

    var body: some View {
        configuration.label
            .font(.body.weight(.medium))
            .foregroundStyle(textColor)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
            .opacity(isEnabled ? 1 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private var backgroundColor: Color {
        if highContrast {
            return isSelected ? Color.white : Color.black.opacity(0.58)
        }
        return isSelected ? EchoTheme.moss.opacity(0.90) : Color.white.opacity(0.82)
    }

    private var textColor: Color {
        if highContrast {
            return isSelected ? EchoTheme.night : Color.white
        }
        return isSelected ? Color.white : EchoTheme.night
    }

    private var borderColor: Color {
        if highContrast {
            return Color.white.opacity(0.9)
        }
        return Color.white.opacity(0.58)
    }
}

struct ProgressPill: View {
    let current: Int
    let total: Int
    let highContrast: Bool

    var body: some View {
        let palette = EchoPalette(highContrast: highContrast)

        Text("Step \(current) of \(total)")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(palette.badgeText)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(palette.badgeBackground)
            )
    }
}

struct StepRail: View {
    let current: Int
    let total: Int
    let highContrast: Bool

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...total, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(index <= current ? activeColor : inactiveColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 6)
            }
        }
    }

    private var activeColor: Color {
        highContrast ? Color.white : EchoTheme.clay
    }

    private var inactiveColor: Color {
        highContrast ? Color.white.opacity(0.30) : Color.white.opacity(0.45)
    }
}

struct InlineBadge: View {
    let title: String
    let systemImage: String
    let highContrast: Bool

    var body: some View {
        let palette = EchoPalette(highContrast: highContrast)

        Label(title, systemImage: systemImage)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(palette.badgeText)
            .padding(.vertical, 7)
            .padding(.horizontal, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(palette.badgeBackground)
            )
    }
}

struct ConfidenceMeter: View {
    let confidence: Double
    let highContrast: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Confidence")
                    .font(.caption.weight(.semibold))
                Spacer()
                Text("\(Int((confidence * 100).rounded()))%")
                    .font(.caption.weight(.semibold))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(highContrast ? Color.white.opacity(0.25) : Color.white.opacity(0.50))
                    Capsule(style: .continuous)
                        .fill(highContrast ? Color.white : EchoTheme.clay)
                        .frame(width: geo.size.width * max(0.05, min(confidence, 1)))
                }
            }
            .frame(height: 8)
        }
    }
}

struct SyllableRow: View {
    let syllables: [String]
    let activeIndex: Int
    let highContrast: Bool

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                chips
            }
            VStack(alignment: .leading, spacing: 8) {
                chips
            }
        }
    }

    @ViewBuilder
    private var chips: some View {
        ForEach(Array(syllables.enumerated()), id: \.offset) { idx, syllable in
            Text(syllable)
                .font(.caption.weight(.semibold))
                .foregroundStyle(chipText(isActive: idx == activeIndex))
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(
                    Capsule(style: .continuous)
                        .fill(chipBackground(isActive: idx == activeIndex))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(highContrast ? Color.white.opacity(0.85) : Color.white.opacity(0.55), lineWidth: 1)
                )
        }
    }

    private func chipBackground(isActive: Bool) -> Color {
        if highContrast {
            return isActive ? Color.white : Color.black.opacity(0.60)
        }
        return isActive ? EchoTheme.clay : Color.white.opacity(0.78)
    }

    private func chipText(isActive: Bool) -> Color {
        if highContrast {
            return isActive ? EchoTheme.night : Color.white
        }
        return isActive ? Color.white : EchoTheme.night
    }
}

struct StaggeredEntrance: ViewModifier {
    let index: Int
    let focusMode: Bool
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 18)
            .onAppear {
                guard !focusMode else {
                    appeared = true
                    return
                }
                withAnimation(
                    .spring(response: 0.5, dampingFraction: 0.8)
                        .delay(Double(index) * 0.08)
                ) {
                    appeared = true
                }
            }
    }
}

struct ScoreReveal: ViewModifier {
    let targetValue: Double
    let format: String
    @State private var displayValue: Double = 0

    init(value: Double, format: String = "%.0f") {
        self.targetValue = value
        self.format = format
    }

    func body(content: Content) -> some View {
        content.overlay {
            Text(String(format: format, displayValue))
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                displayValue = targetValue
            }
        }
        .onChange(of: targetValue) { _, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                displayValue = newValue
            }
        }
    }
}

extension View {
    func scoreReveal(value: Double, format: String = "%.0f") -> some View {
        modifier(ScoreReveal(value: value, format: format))
    }
}
