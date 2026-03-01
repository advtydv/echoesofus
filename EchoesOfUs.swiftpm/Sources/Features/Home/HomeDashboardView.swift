import SwiftUI

struct HomeDashboardView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        let hc = appState.learnerProfile.highContrast

        ZStack {
            EchoBackdrop(
                highContrast: hc,
                focusMode: appState.learnerProfile.focusMode
            )

            GeometryReader { geo in
                VStack(spacing: 0) {
                    heroSection(topInset: geo.safeAreaInsets.top, hc: hc)
                    tilesSection(hc: hc, bottomInset: geo.safeAreaInsets.bottom)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
    }

    // MARK: - Hero

    private func heroSection(topInset: CGFloat, hc: Bool) -> some View {
        let palette = appState.learnerProfile.palette

        return VStack(spacing: 20) {
            Spacer(minLength: topInset + 44)

            VStack(spacing: 6) {
                Text("Echoes of Us")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.backdropText)
                Text("Preserve language. Promote equity.")
                    .font(.subheadline)
                    .foregroundStyle(palette.backdropSubtext)
            }
            .multilineTextAlignment(.center)

            Button(action: { appState.startGuidedJourney() }) {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill").font(.subheadline.weight(.semibold))
                    Text("Start Guided Journey").font(.headline)
                }
                .foregroundStyle(hc ? EchoTheme.night : .white)
                .frame(maxWidth: 300)
                .padding(.vertical, 15)
                .background(
                    Capsule(style: .continuous)
                        .fill(hc
                            ? AnyShapeStyle(Color.white)
                            : AnyShapeStyle(LinearGradient(
                                colors: [EchoTheme.clay, EchoTheme.clayDark],
                                startPoint: .leading, endPoint: .trailing))
                        )
                )
                .shadow(color: EchoTheme.clay.opacity(hc ? 0 : 0.35), radius: 14, y: 6)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 24)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Tiles

    private func tilesSection(hc: Bool, bottomInset: CGFloat) -> some View {
        let palette = appState.learnerProfile.palette

        return VStack(alignment: .leading, spacing: 16) {
            // Language picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Language")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.backdropSubtext)
                    .padding(.leading, 2)

                HStack(spacing: 10) {
                    ForEach(appState.languagePacks) { pack in
                        LanguageChip(
                            name: pack.name,
                            region: pack.region,
                            isSelected: appState.activeLanguageID == pack.id,
                            hc: hc
                        ) {
                            appState.selectLanguage(pack.id)
                        }
                    }
                }
            }

            // Activity tiles
            VStack(alignment: .leading, spacing: 8) {
                Text("Activities")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.backdropSubtext)
                    .padding(.leading, 2)

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    HomeTile(icon: "book.closed.fill", label: "Learn", description: "Browse phrases", color: EchoTheme.clay, hc: hc) {
                        appState.learnMode = .library
                        appState.openQuickAccess(step: .learn)
                    }
                    HomeTile(icon: "target", label: "Practice", description: "Mastery sprint", color: EchoTheme.moss, hc: hc) {
                        appState.openQuickAccess(step: .mastery)
                    }
                    HomeTile(icon: "checkmark.message.fill", label: "Missions", description: "Real scenarios", color: Color(red: 0.45, green: 0.40, blue: 0.70), hc: hc) {
                        appState.openQuickAccess(step: .mission)
                    }
                    HomeTile(icon: "bubble.left.and.bubble.right", label: "Talk", description: "Conversation sim", color: Color(red: 0.22, green: 0.53, blue: 0.67), hc: hc) {
                        appState.openQuickAccess(step: .conversation)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, bottomInset + 20)
    }
}

// MARK: - Language Chip

private struct LanguageChip: View {
    let name: String
    let region: String
    let isSelected: Bool
    let hc: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected
                            ? (hc ? Color.white : EchoTheme.clay)
                            : Color.clear)
                        .frame(width: 8, height: 8)
                    Circle()
                        .stroke(hc ? Color.white.opacity(0.5) : EchoTheme.clay.opacity(0.4), lineWidth: 1)
                        .frame(width: 8, height: 8)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(shortName(name))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected
                            ? (hc ? .white : EchoTheme.clay)
                            : (hc ? Color.white.opacity(0.55) : EchoTheme.night.opacity(0.5)))
                    Text(region)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(hc ? Color.white.opacity(0.4) : EchoTheme.night.opacity(0.35))
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected
                        ? (hc ? Color.white.opacity(0.15) : EchoTheme.clay.opacity(0.10))
                        : (hc ? Color.white.opacity(0.05) : Color.white.opacity(0.45)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected
                        ? (hc ? Color.white.opacity(0.4) : EchoTheme.clay.opacity(0.35))
                        : Color.clear,
                        lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Select \(name)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func shortName(_ fullName: String) -> String {
        if fullName.contains("Navajo") { return "Navajo" }
        if fullName.contains("Quechua") { return "Quechua" }
        return fullName.components(separatedBy: " ").first ?? fullName
    }
}

// MARK: - Activity Tile

private struct HomeTile: View {
    let icon: String
    let label: String
    let description: String
    let color: Color
    let hc: Bool
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(hc ? Color.white.opacity(0.15) : color.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(hc ? .white : color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(hc ? .white : EchoTheme.night)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(hc ? Color.white.opacity(0.5) : EchoTheme.night.opacity(0.4))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(hc ? Color.white.opacity(0.08) : Color.white.opacity(0.65))
                    .shadow(color: .black.opacity(hc ? 0.2 : 0.07), radius: 8, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(hc ? Color.white.opacity(0.15) : Color.white.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(pressed ? 0.96 : 1)
        .animation(.easeOut(duration: 0.12), value: pressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
        .accessibilityLabel(label)
        .accessibilityHint(description)
    }
}
