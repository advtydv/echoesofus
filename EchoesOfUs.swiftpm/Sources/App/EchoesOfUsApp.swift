import SwiftUI

@main
struct EchoesOfUsApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            GuidedRootView()
                .environmentObject(appState)
        }
    }
}

struct GuidedRootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        switch appState.route {
        case .dashboard:
            HomeDashboardView()
        case .guided:
            GuidedExperienceView()
        case .studio:
            LearningStudioView()
        }
    }
}

private struct GuidedExperienceView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        let palette = appState.learnerProfile.palette

        return ZStack {
            EchoBackdrop(
                highContrast: appState.learnerProfile.highContrast,
                focusMode: appState.learnerProfile.focusMode
            )

            VStack(spacing: 0) {
                if let issue = appState.loadIssueMessage {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(issue)
                            .lineLimit(2)
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(palette.warningText)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(palette.warningBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.bottom, 8)
                }

                contentForCurrentStep
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .animation(appState.learnerProfile.focusMode ? nil : .easeInOut(duration: 0.30), value: appState.step)
    }

    @ViewBuilder
    private var contentForCurrentStep: some View {
        switch appState.step {
        case .intro:
            IntroView()
        case .setup:
            InclusionSetupView()
        case .learn:
            LearnView()
        case .mastery:
            MasterySprintView()
        case .mission:
            MissionView()
        case .conversation:
            ConversationSimView()
        case .fairness:
            FairnessLabView()
        case .summary:
            ImpactSummaryView()
        }
    }
}

struct StageShell<Content: View>: View {
    @EnvironmentObject private var appState: AppState
    let title: String
    let subtitle: String
    let content: Content

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        let palette = appState.learnerProfile.palette

        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    Button(action: { appState.goBackStep() }) {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(palette.badgeText)
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(palette.badgeBackground))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back")

                    Button(action: { appState.goToDashboard() }) {
                        Image(systemName: "house")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(palette.badgeText)
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(palette.badgeBackground))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Home")

                    Spacer()

                    Text("Step \(appState.step.rawValue + 1) of \(GuidedStep.allCases.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(palette.cardSubtext)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(palette.cardText)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(palette.cardSubtext)
                }

                StepRail(
                    current: appState.step.rawValue + 1,
                    total: GuidedStep.allCases.count,
                    highContrast: appState.learnerProfile.highContrast
                )

                content
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
            .padding(.bottom, 24)
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity, alignment: .top)
        }
    }
}
