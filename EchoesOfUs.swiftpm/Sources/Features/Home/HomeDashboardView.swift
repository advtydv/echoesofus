import SwiftUI

struct HomeDashboardView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        let palette = appState.learnerProfile.palette

        return ZStack {
            EchoBackdrop(
                highContrast: appState.learnerProfile.highContrast,
                focusMode: appState.learnerProfile.focusMode
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Echoes of Us")
                            .font(.largeTitle.weight(.bold))
                        Text("An inclusive, offline language learning experience designed for AI equity.")
                            .font(.subheadline)
                            .readableText(appState.learnerProfile.readingSupport)
                            .foregroundStyle(palette.backdropSubtext)

                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: 8) {
                                InlineBadge(title: "Offline-first", systemImage: "wifi.slash", highContrast: appState.learnerProfile.highContrast)
                                InlineBadge(title: "Accessibility-led", systemImage: "accessibility", highContrast: appState.learnerProfile.highContrast)
                                InlineBadge(title: "Navajo + Quechua", systemImage: "globe.americas", highContrast: appState.learnerProfile.highContrast)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                InlineBadge(title: "Offline-first", systemImage: "wifi.slash", highContrast: appState.learnerProfile.highContrast)
                                InlineBadge(title: "Accessibility-led", systemImage: "accessibility", highContrast: appState.learnerProfile.highContrast)
                                InlineBadge(title: "Navajo + Quechua", systemImage: "globe.americas", highContrast: appState.learnerProfile.highContrast)
                            }
                        }
                    }
                    .foregroundStyle(palette.backdropText)

                    VStack(spacing: 10) {
                        DashboardActionCard(
                            title: "Resume Guided Journey",
                            subtitle: "Follow the official judged narrative from intro to impact summary.",
                            systemImage: "play.circle.fill",
                            highContrast: appState.learnerProfile.highContrast
                        ) {
                            appState.startGuidedJourney()
                        }
                        .staggeredEntrance(index: 0, focusMode: appState.learnerProfile.focusMode)

                        DashboardActionCard(
                            title: "Phrase Library",
                            subtitle: "Browse all phrases by language and category with audio support.",
                            systemImage: "books.vertical.fill",
                            highContrast: appState.learnerProfile.highContrast
                        ) {
                            appState.learnMode = .library
                            appState.openQuickAccess(step: .learn)
                        }
                        .staggeredEntrance(index: 1, focusMode: appState.learnerProfile.focusMode)

                        DashboardActionCard(
                            title: "Mastery Practice",
                            subtitle: "Run adaptive prompts and improve weak-phrase confidence.",
                            systemImage: "target",
                            highContrast: appState.learnerProfile.highContrast
                        ) {
                            appState.openQuickAccess(step: .mastery)
                        }
                        .staggeredEntrance(index: 2, focusMode: appState.learnerProfile.focusMode)

                        DashboardActionCard(
                            title: "Mission Scenarios",
                            subtitle: "Practice classroom and community responses in context.",
                            systemImage: "checkmark.message.fill",
                            highContrast: appState.learnerProfile.highContrast
                        ) {
                            appState.openQuickAccess(step: .mission)
                        }
                        .staggeredEntrance(index: 3, focusMode: appState.learnerProfile.focusMode)

                        DashboardActionCard(
                            title: "Echo Chamber",
                            subtitle: "Practice phrases in a realistic conversation with characters.",
                            systemImage: "bubble.left.and.bubble.right",
                            highContrast: appState.learnerProfile.highContrast
                        ) {
                            appState.openQuickAccess(step: .conversation)
                        }
                        .staggeredEntrance(index: 4, focusMode: appState.learnerProfile.focusMode)

                        DashboardActionCard(
                            title: "AI Fairness Lab",
                            subtitle: "Explore how community contributions affect model outcomes.",
                            systemImage: "chart.bar.xaxis",
                            highContrast: appState.learnerProfile.highContrast
                        ) {
                            appState.openQuickAccess(step: .fairness)
                        }
                        .staggeredEntrance(index: 5, focusMode: appState.learnerProfile.focusMode)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Audio readiness")
                            .font(.headline)
                        Text(appState.audioCoverageText)
                            .font(.subheadline)
                            .foregroundStyle(palette.cardSubtext)
                        Text(appState.hasCompleteAudioCoverage ? "All manifest clips are available locally." : "Missing clips will use helper narration fallback.")
                            .font(.footnote)
                            .foregroundStyle(palette.cardSubtext)
                    }
                    .foregroundStyle(palette.cardText)
                    .echoCard(highContrast: appState.learnerProfile.highContrast)
                }
                .padding(16)
                .frame(maxWidth: 860)
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
    }
}

private struct DashboardActionCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let highContrast: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(highContrast ? Color.white.opacity(0.18) : Color.white.opacity(0.72))
                        .frame(width: 40, height: 40)
                    Image(systemName: systemImage)
                        .font(.headline)
                        .foregroundStyle(highContrast ? Color.white : EchoTheme.clay)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.footnote)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .padding(.top, 2)
            }
            .foregroundStyle(highContrast ? Color.white : EchoTheme.night)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(14)
        .echoCard(highContrast: highContrast)
    }
}
