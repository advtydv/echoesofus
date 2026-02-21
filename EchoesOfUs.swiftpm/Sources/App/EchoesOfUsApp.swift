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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 14) {
                    StageControlRow(
                        highContrast: appState.learnerProfile.highContrast,
                        currentStep: appState.step,
                        canJump: { appState.canJump(to: $0) },
                        onStepTap: { appState.jump(to: $0) },
                        onBack: { appState.goBackStep() },
                        onHome: { appState.goToDashboard() }
                    )

                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .top, spacing: 12) {
                            stageIdentity
                            Spacer()
                            ProgressPill(
                                current: appState.step.rawValue + 1,
                                total: GuidedStep.allCases.count,
                                highContrast: appState.learnerProfile.highContrast
                            )
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            stageIdentity
                            ProgressPill(
                                current: appState.step.rawValue + 1,
                                total: GuidedStep.allCases.count,
                                highContrast: appState.learnerProfile.highContrast
                            )
                        }
                    }

                    StepJumpRail(
                        currentStep: appState.step,
                        highContrast: appState.learnerProfile.highContrast,
                        canJump: { appState.canJump(to: $0) },
                        onStepTap: { appState.jump(to: $0) }
                    )
                }
                .echoCard(highContrast: appState.learnerProfile.highContrast)

                content
            }
            .padding(.top, 6)
            .padding(.bottom, 24)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity, alignment: .top)
        }
    }

    private var stageIdentity: some View {
        let palette = appState.learnerProfile.palette

        return HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(palette.badgeBackground)
                    .frame(width: 46, height: 46)
                Image(systemName: symbolForStep(appState.step))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(palette.badgeIcon)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(palette.cardText)
                    .readableText(appState.learnerProfile.readingSupport)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(palette.cardSubtext)
                    .readableText(appState.learnerProfile.readingSupport)
                InlineBadge(
                    title: appState.guidedMode == .judged ? "3-minute guided flow" : "Quick access mode",
                    systemImage: appState.guidedMode == .judged ? "timer" : "square.grid.2x2",
                    highContrast: appState.learnerProfile.highContrast
                )
                .padding(.top, 4)
            }
        }
    }

    private func symbolForStep(_ step: GuidedStep) -> String {
        switch step {
        case .intro:
            return "sparkles"
        case .setup:
            return "slider.horizontal.3"
        case .learn:
            return "book.closed"
        case .mastery:
            return "figure.mind.and.body"
        case .mission:
            return "checkmark.message"
        case .fairness:
            return "chart.bar.xaxis"
        case .summary:
            return "heart.text.square"
        }
    }
}

private struct StageControlRow: View {
    let highContrast: Bool
    let currentStep: GuidedStep
    let canJump: (GuidedStep) -> Bool
    let onStepTap: (GuidedStep) -> Void
    let onBack: () -> Void
    let onHome: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            StageControlButton(title: "Back", systemImage: "chevron.left", highContrast: highContrast, action: onBack)
            StageControlButton(title: "Home", systemImage: "house", highContrast: highContrast, action: onHome)
            Menu {
                ForEach(GuidedStep.allCases) { step in
                    Button {
                        onStepTap(step)
                    } label: {
                        Label(
                            step.title,
                            systemImage: canJump(step) ? "lock.open" : "lock"
                        )
                    }
                    .disabled(!canJump(step) || step == currentStep)
                }
            } label: {
                Label("Jump", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(EchoPalette(highContrast: highContrast).badgeText)
                    .padding(.vertical, 7)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule(style: .continuous)
                            .fill(EchoPalette(highContrast: highContrast).badgeBackground)
                    )
            }
            Spacer()
        }
    }
}

private struct StageControlButton: View {
    let title: String
    let systemImage: String
    let highContrast: Bool
    let action: () -> Void

    var body: some View {
        let palette = EchoPalette(highContrast: highContrast)

        return Button(action: action) {
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
        .buttonStyle(PlainButtonStyle())
    }
}

private struct StepJumpRail: View {
    let currentStep: GuidedStep
    let highContrast: Bool
    let canJump: (GuidedStep) -> Bool
    let onStepTap: (GuidedStep) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(GuidedStep.allCases) { step in
                Button {
                    onStepTap(step)
                } label: {
                    VStack(spacing: 4) {
                        Capsule(style: .continuous)
                            .fill(fillColor(for: step))
                            .frame(maxWidth: .infinity)
                            .frame(height: 6)

                        Image(systemName: canJump(step) ? "lock.open" : "lock")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(canJump(step) ? unlockedIconColor : lockedIconColor)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!canJump(step))
                .accessibilityLabel(step.title)
                .accessibilityHint(canJump(step) ? "Jump to this step" : "Locked until you complete earlier steps")
            }
        }
    }

    private func fillColor(for step: GuidedStep) -> Color {
        if step.rawValue < currentStep.rawValue {
            return highContrast ? Color.white : EchoTheme.clay
        }
        if step == currentStep {
            return highContrast ? Color.white.opacity(0.85) : EchoTheme.moss
        }
        return highContrast ? Color.white.opacity(0.22) : Color.white.opacity(0.42)
    }

    private var unlockedIconColor: Color {
        highContrast ? Color.white : EchoTheme.night.opacity(0.75)
    }

    private var lockedIconColor: Color {
        highContrast ? Color.white.opacity(0.55) : EchoTheme.night.opacity(0.42)
    }
}
