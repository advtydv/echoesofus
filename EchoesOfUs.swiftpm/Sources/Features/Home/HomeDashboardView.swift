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
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Echoes of Us")
                            .font(.largeTitle.weight(.bold))
                        Text("Preserve language. Promote equity.")
                            .font(.subheadline)
                            .foregroundStyle(palette.backdropSubtext)
                    }
                    .foregroundStyle(palette.backdropText)

                    DashboardActionCard(
                        title: "Begin Guided Journey",
                        icon: "play.circle.fill",
                        accent: EchoTheme.clay,
                        highContrast: appState.learnerProfile.highContrast
                    ) {
                        appState.startGuidedJourney()
                    }
                    .staggeredEntrance(index: 0, focusMode: appState.learnerProfile.focusMode)

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        QuickAccessTile(title: "Phrases", icon: "book.closed.fill", highContrast: appState.learnerProfile.highContrast) {
                            appState.learnMode = .library
                            appState.openQuickAccess(step: .learn)
                        }
                        .staggeredEntrance(index: 1, focusMode: appState.learnerProfile.focusMode)

                        QuickAccessTile(title: "Practice", icon: "target", highContrast: appState.learnerProfile.highContrast) {
                            appState.openQuickAccess(step: .mastery)
                        }
                        .staggeredEntrance(index: 2, focusMode: appState.learnerProfile.focusMode)

                        QuickAccessTile(title: "Missions", icon: "checkmark.message.fill", highContrast: appState.learnerProfile.highContrast) {
                            appState.openQuickAccess(step: .mission)
                        }
                        .staggeredEntrance(index: 3, focusMode: appState.learnerProfile.focusMode)

                        QuickAccessTile(title: "Echo Chamber", icon: "bubble.left.and.bubble.right", highContrast: appState.learnerProfile.highContrast) {
                            appState.openQuickAccess(step: .conversation)
                        }
                        .staggeredEntrance(index: 4, focusMode: appState.learnerProfile.focusMode)

                        QuickAccessTile(title: "AI Fairness", icon: "chart.bar.xaxis", highContrast: appState.learnerProfile.highContrast) {
                            appState.openQuickAccess(step: .fairness)
                        }
                        .staggeredEntrance(index: 5, focusMode: appState.learnerProfile.focusMode)
                    }
                }
                .padding(20)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
    }
}

private struct DashboardActionCard: View {
    let title: String
    let icon: String
    let accent: Color
    let highContrast: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(highContrast ? .white : accent)

                Text(title)
                    .font(.headline)

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(highContrast ? .white : EchoTheme.night)
            .padding(16)
        }
        .buttonStyle(.plain)
        .echoCard(highContrast: highContrast)
    }
}

private struct QuickAccessTile: View {
    let title: String
    let icon: String
    let highContrast: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(highContrast ? .white : EchoTheme.clay)

                Text(title)
                    .font(.footnote.weight(.semibold))
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(highContrast ? .white : EchoTheme.night)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
        .buttonStyle(.plain)
        .echoCard(highContrast: highContrast)
    }
}
