import SwiftUI

struct InclusionSetupView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        let palette = appState.learnerProfile.palette

        return StageShell(
            title: "Inclusion Setup",
            subtitle: "Tune the experience so learning stays accessible and comfortable."
        ) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Accessibility profile")
                    .font(.headline)
                Text("These preferences apply instantly and stay active across learning, mastery, and mission tasks.")
                    .font(.subheadline)
                    .foregroundStyle(palette.cardSubtext)
                    .readableText(appState.learnerProfile.readingSupport)
            }
            .foregroundStyle(palette.cardText)
            .echoCard(highContrast: appState.learnerProfile.highContrast)

            VStack(spacing: 12) {
                ToggleRow(
                    title: "High contrast",
                    caption: "Boost readability and keep critical elements visible.",
                    isOn: $appState.learnerProfile.highContrast
                )
                ToggleRow(
                    title: "Focus mode",
                    caption: "Reduce decorative motion to minimize distraction.",
                    isOn: $appState.learnerProfile.focusMode
                )
                ToggleRow(
                    title: "Reading support",
                    caption: "Use easier spacing and rounded text forms.",
                    isOn: $appState.learnerProfile.readingSupport
                )
                ToggleRow(
                    title: "Bilingual hints",
                    caption: "Allow language-specific hints during missions.",
                    isOn: $appState.learnerProfile.bilingualHints
                )
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    modeBadges
                }
                VStack(alignment: .leading, spacing: 8) {
                    modeBadges
                }
            }

            Button("Continue to learning") {
                appState.advanceStep()
            }
            .buttonStyle(PrimaryActionButton(highContrast: appState.learnerProfile.highContrast))
        }
    }

    @ViewBuilder
    private var modeBadges: some View {
        InlineBadge(
            title: appState.learnerProfile.focusMode ? "Calm motion" : "Standard motion",
            systemImage: appState.learnerProfile.focusMode ? "leaf" : "sparkles",
            highContrast: appState.learnerProfile.highContrast
        )
        InlineBadge(
            title: appState.learnerProfile.readingSupport ? "Reading support on" : "Standard typography",
            systemImage: "textformat.size",
            highContrast: appState.learnerProfile.highContrast
        )
        InlineBadge(
            title: appState.learnerProfile.bilingualHints ? "Bilingual hints on" : "General hints only",
            systemImage: "text.bubble",
            highContrast: appState.learnerProfile.highContrast
        )
    }
}

private struct ToggleRow: View {
    @EnvironmentObject private var appState: AppState
    let title: String
    let caption: String
    @Binding var isOn: Bool

    var body: some View {
        let palette = appState.learnerProfile.palette

        return Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(caption)
                    .font(.footnote)
                    .foregroundStyle(palette.cardSubtext)
            }
            .foregroundStyle(palette.cardText)
        }
        .tint(EchoTheme.clay)
        .padding(14)
        .echoCard(highContrast: appState.learnerProfile.highContrast)
        .toggleStyle(SwitchToggleStyle(tint: EchoTheme.clay))
    }
}
