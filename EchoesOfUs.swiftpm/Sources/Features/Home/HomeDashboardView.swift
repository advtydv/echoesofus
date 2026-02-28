import SwiftUI

struct HomeDashboardView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        let palette = appState.learnerProfile.palette
        let hc = appState.learnerProfile.highContrast

        return ZStack {
            EchoBackdrop(
                highContrast: hc,
                focusMode: appState.learnerProfile.focusMode
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    Spacer(minLength: 40)

                    VStack(spacing: 8) {
                        Text("Echoes of Us")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(palette.backdropText)

                        Text("Preserve language. Promote equity.")
                            .font(.subheadline)
                            .foregroundStyle(palette.backdropSubtext)
                    }
                    .multilineTextAlignment(.center)

                    Button {
                        appState.startGuidedJourney()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                                .font(.body)
                            Text("Start Guided Journey")
                                .font(.headline)
                        }
                        .foregroundStyle(hc ? EchoTheme.night : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    hc
                                    ? AnyShapeStyle(Color.white)
                                    : AnyShapeStyle(LinearGradient(
                                        colors: [EchoTheme.clay, EchoTheme.clayDark],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                )
                        )
                        .shadow(color: .black.opacity(0.12), radius: 10, y: 5)
                    }
                    .buttonStyle(.plain)

                    VStack(spacing: 10) {
                        Text("Quick Access")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(palette.backdropSubtext)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10)
                        ], spacing: 10) {
                            QuickTile(icon: "book.closed.fill", label: "Learn", hc: hc) {
                                appState.learnMode = .library
                                appState.openQuickAccess(step: .learn)
                            }
                            QuickTile(icon: "target", label: "Practice", hc: hc) {
                                appState.openQuickAccess(step: .mastery)
                            }
                            QuickTile(icon: "checkmark.message.fill", label: "Missions", hc: hc) {
                                appState.openQuickAccess(step: .mission)
                            }
                            QuickTile(icon: "bubble.left.and.bubble.right", label: "Talk", hc: hc) {
                                appState.openQuickAccess(step: .conversation)
                            }
                            QuickTile(icon: "chart.bar.xaxis", label: "Fairness", hc: hc) {
                                appState.openQuickAccess(step: .fairness)
                            }
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: 440)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct QuickTile: View {
    let icon: String
    let label: String
    let hc: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(hc ? .white : EchoTheme.clay)
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(hc ? .white : EchoTheme.night)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(hc ? Color.white.opacity(0.10) : Color.white.opacity(0.55))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(hc ? Color.white.opacity(0.2) : Color.white.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
