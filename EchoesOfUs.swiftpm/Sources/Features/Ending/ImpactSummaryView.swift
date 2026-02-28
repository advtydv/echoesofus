import SwiftUI

struct ImpactSummaryView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        let palette = appState.learnerProfile.palette

        return StageShell(
            title: "Impact Summary",
            subtitle: "Inclusion becomes real when learning tools respect language diversity."
        ) {
            VStack(alignment: .leading, spacing: 8) {
                Label("You completed the guided experience", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                Text("This demo combines accessibility, language respect, and AI fairness in a single offline learning flow.")
                    .font(.subheadline)
                    .readableText(appState.learnerProfile.readingSupport)
            }
            .foregroundStyle(palette.cardText)
            .echoCard(highContrast: appState.learnerProfile.highContrast)

            VStack(alignment: .leading, spacing: 12) {
                Text("Session highlights")
                    .font(.headline)
                    .foregroundStyle(palette.cardText)

                metricRow(title: "Guided time", value: "\(appState.sessionDuration)s")
                metricRow(title: "Missions completed", value: "\(appState.completedMissions)")
                metricRow(title: "Adaptive hints used", value: "\(appState.hintsUsed)")
                metricRow(title: "Mastery sprint score", value: "\(appState.lastSprintScore)/4")
                metricRow(title: "Mastery confidence shift", value: String(format: "%+.1f%%", appState.masteryDelta * 100))
                metricRow(title: "Conversation fluency", value: "\(Int((appState.conversationFluencyScore * 100).rounded()))%")
                metricRow(title: "Low-resource readiness", value: String(format: "%.1f", appState.lowResourceScore))
                metricRow(title: "Native clips heard", value: "\(appState.audioClipPlayCount)")
                metricRow(title: "Fallback narration used", value: "\(appState.audioFallbackCount)")
            }
            .echoCard(highContrast: appState.learnerProfile.highContrast)

            VStack(alignment: .leading, spacing: 8) {
                Text("Audio coverage status")
                    .font(.headline)
                Text(appState.audioCoverageText)
                    .font(.subheadline)
                    .foregroundStyle(palette.cardSubtext)
                Text(appState.hasCompleteAudioCoverage ? "Coverage complete: all manifest clips available locally." : "Coverage in progress: missing clips use helper narration offline.")
                    .font(.footnote)
                    .foregroundStyle(palette.cardSubtext)
            }
            .foregroundStyle(palette.cardText)
            .echoCard(highContrast: appState.learnerProfile.highContrast)

            VStack(alignment: .leading, spacing: 8) {
                Text("Call to action")
                    .font(.headline)
                Text("Language inclusion is not only preservation. It is equal access to future tools, opportunity, and voice in the AI era.")
                    .font(.body)
                    .readableText(appState.learnerProfile.readingSupport)
            }
            .foregroundStyle(palette.cardText)
            .echoCard(highContrast: appState.learnerProfile.highContrast)

            VStack(alignment: .leading, spacing: 8) {
                Text("How this was designed responsibly")
                    .font(.headline)
                Text("This app stays fully offline, uses curated educational content, and clearly labels helper narration so it is never mistaken for native-speaker authority.")
                    .font(.footnote)
                    .foregroundStyle(palette.cardSubtext)
                    .readableText(appState.learnerProfile.readingSupport)
            }
            .foregroundStyle(palette.cardText)
            .echoCard(highContrast: appState.learnerProfile.highContrast)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    InlineBadge(title: "Education", systemImage: "book.pages", highContrast: appState.learnerProfile.highContrast)
                    InlineBadge(title: "Inclusivity", systemImage: "person.2.fill", highContrast: appState.learnerProfile.highContrast)
                    InlineBadge(title: "AI Equity", systemImage: "cpu", highContrast: appState.learnerProfile.highContrast)
                }
                VStack(alignment: .leading, spacing: 8) {
                    InlineBadge(title: "Education", systemImage: "book.pages", highContrast: appState.learnerProfile.highContrast)
                    InlineBadge(title: "Inclusivity", systemImage: "person.2.fill", highContrast: appState.learnerProfile.highContrast)
                    InlineBadge(title: "AI Equity", systemImage: "cpu", highContrast: appState.learnerProfile.highContrast)
                }
            }

            Button("Open Learning Studio") {
                appState.route = .studio
            }
            .buttonStyle(SecondaryActionButton(highContrast: appState.learnerProfile.highContrast))

            Button("Restart guided demo") {
                appState.restartDemo()
            }
            .buttonStyle(PrimaryActionButton(highContrast: appState.learnerProfile.highContrast))
        }
    }

    private func metricRow(title: String, value: String) -> some View {
        let palette = appState.learnerProfile.palette

        return HStack {
            Text(title)
            Spacer()
            Text(value).fontWeight(.semibold)
        }
        .foregroundStyle(palette.cardText)
        .font(.subheadline)
    }
}
