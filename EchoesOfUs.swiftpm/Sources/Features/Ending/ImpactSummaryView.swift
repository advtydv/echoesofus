import SwiftUI

struct ImpactSummaryView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        StageShell(
            title: "Impact Summary",
            subtitle: "Your journey through language, culture, and AI equity."
        ) {
            completionCard
            metricsCard
            callToActionCard
            actionButtons
        }
    }

    private var completionCard: some View {
        let palette = appState.learnerProfile.palette
        return VStack(alignment: .leading, spacing: 8) {
            Label("Journey Complete", systemImage: "checkmark.circle.fill")
                .font(.headline)
            Text("You explored accessibility, language respect, and AI fairness in a single offline learning flow.")
                .font(.subheadline)
                .readableText(appState.learnerProfile.readingSupport)
        }
        .foregroundStyle(palette.cardText)
        .echoCard(highContrast: appState.learnerProfile.highContrast)
    }

    private var metricsCard: some View {
        let palette = appState.learnerProfile.palette
        let hc = appState.learnerProfile.highContrast
        return VStack(alignment: .leading, spacing: 12) {
            Text("Session highlights")
                .font(.headline)
                .foregroundStyle(palette.cardText)

            metricRow("Guided time", value: "\(appState.sessionDuration)s")
            metricRow("Missions completed", value: "\(appState.completedMissions)")
            metricRow("Hints used", value: "\(appState.hintsUsed)")
            metricRow("Sprint score", value: "\(appState.lastSprintScore)/4")
            metricRow("Conversation fluency", value: "\(Int((appState.conversationFluencyScore * 100).rounded()))%")
        }
        .echoCard(highContrast: hc)
    }

    private var callToActionCard: some View {
        let palette = appState.learnerProfile.palette
        return VStack(alignment: .leading, spacing: 8) {
            Text("Why it matters")
                .font(.headline)
            Text("Language inclusion means equal access to tools, opportunity, and voice in the AI era.")
                .font(.subheadline)
                .readableText(appState.learnerProfile.readingSupport)
        }
        .foregroundStyle(palette.cardText)
        .echoCard(highContrast: appState.learnerProfile.highContrast)
    }

    private var actionButtons: some View {
        let hc = appState.learnerProfile.highContrast
        return VStack(spacing: 10) {
            Button("Restart guided demo") {
                appState.restartDemo()
            }
            .buttonStyle(PrimaryActionButton(highContrast: hc))

            Button("Back to home") {
                appState.goToDashboard()
            }
            .buttonStyle(SecondaryActionButton(highContrast: hc))
        }
    }

    private func metricRow(_ title: String, value: String) -> some View {
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
