import SwiftUI

struct MissionView: View {
    @EnvironmentObject private var appState: AppState
    @State private var shownHint: String?

    var body: some View {
        let palette = appState.learnerProfile.palette

        return StageShell(
            title: "Inclusive Mission",
            subtitle: "Apply language choices to realistic classroom and community moments."
        ) {
            if let mission = appState.currentMission {
                missionContent(mission: mission, palette: palette)
            } else {
                emptyMissionContent(palette: palette)
            }
        }
    }

    @ViewBuilder
    private func missionContent(mission: Mission, palette: EchoPalette) -> some View {
        missionPromptCard(mission: mission, palette: palette)
        missionOptionsSection(mission: mission, palette: palette)
        missionFeedbackSection(palette: palette)
    }

    private func missionPromptCard(mission: Mission, palette: EchoPalette) -> some View {
        let languageName = appState.languagePacks.first(where: { $0.id == mission.languageID })?.name ?? mission.languageID

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(languageName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.cardSubtext)
                Spacer()
                InlineBadge(
                    title: "Scenario \(appState.missionIndex + 1)/\(max(1, appState.missions.count))",
                    systemImage: "target",
                    highContrast: appState.learnerProfile.highContrast
                )
            }

            Text(mission.prompt)
                .font(.title3.weight(.semibold))
                .readableText(appState.learnerProfile.readingSupport)
                .foregroundStyle(palette.cardText)

            Button {
                appState.playMissionPromptAudio(for: mission)
            } label: {
                Label("Play scenario audio", systemImage: "speaker.wave.2.fill")
            }
            .buttonStyle(SecondaryActionButton(highContrast: appState.learnerProfile.highContrast))
            .accessibilityLabel("Play scenario audio")
            .accessibilityHint("Plays audio for the mission prompt")

            Text("Audio source: \(appState.lastAudioPlaybackLabel)")
                .font(.footnote)
                .foregroundStyle(palette.cardSubtext)

            Text("Use what you practiced in mastery sprint: meaning + respectful context.")
                .font(.footnote)
                .foregroundStyle(palette.cardSubtext)
        }
        .echoCard(highContrast: appState.learnerProfile.highContrast)
    }

    private func missionOptionsSection(mission: Mission, palette: EchoPalette) -> some View {
        let hc = appState.learnerProfile.highContrast

        return VStack(spacing: 10) {
            ForEach(Array(mission.options.enumerated()), id: \.offset) { index, option in
                MissionOptionRow(
                    option: option,
                    index: index,
                    mission: mission,
                    isSelected: appState.selectedMissionOption == option,
                    isLocked: appState.missionResult == .correct,
                    highContrast: hc,
                    onSelect: {
                        shownHint = nil
                        appState.submitMissionOption(option)
                    },
                    onPlayAudio: {
                        appState.playMissionOptionAudio(mission: mission, optionIndex: index, optionText: option)
                    }
                )
            }
        }
    }

    @ViewBuilder
    private func missionFeedbackSection(palette: EchoPalette) -> some View {
        if appState.missionResult == .incorrect {
            VStack(alignment: .leading, spacing: 10) {
                Label("Not quite yet", systemImage: "arrow.triangle.2.circlepath.circle.fill")
                    .font(.headline)
                    .foregroundStyle(palette.cardText)

                Button("Show adaptive hint") {
                    shownHint = appState.requestHint()
                }
                .buttonStyle(SecondaryActionButton(highContrast: appState.learnerProfile.highContrast))

                if let shownHint {
                    Text(shownHint)
                        .font(.subheadline)
                        .foregroundStyle(palette.cardSubtext)
                        .readableText(appState.learnerProfile.readingSupport)
                        .echoCard(highContrast: appState.learnerProfile.highContrast)
                }
            }
            .echoCard(highContrast: appState.learnerProfile.highContrast)
        }

        if appState.missionResult == .correct {
            VStack(alignment: .leading, spacing: 8) {
                Label("Correct. Great work.", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(palette.cardText)
                Text("Recommended next difficulty: \(appState.recommendedDifficulty)/5")
                    .font(.footnote)
                    .foregroundStyle(palette.cardSubtext)

                Button(appState.missionIndex < appState.missions.count - 1 ? "Next mission" : "Continue to Echo Chamber") {
                    shownHint = nil
                    appState.goToNextMissionOrFinish()
                }
                .buttonStyle(PrimaryActionButton(highContrast: appState.learnerProfile.highContrast))
            }
            .echoCard(highContrast: appState.learnerProfile.highContrast)
        }
    }

    private func emptyMissionContent(palette: EchoPalette) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No mission data available.")
                .foregroundStyle(palette.cardText)

            Button("Continue") {
                appState.advanceStep()
            }
            .buttonStyle(PrimaryActionButton(highContrast: appState.learnerProfile.highContrast))
        }
        .echoCard(highContrast: appState.learnerProfile.highContrast)
    }
}

private struct MissionOptionRow: View {
    let option: String
    let index: Int
    let mission: Mission
    let isSelected: Bool
    let isLocked: Bool
    let highContrast: Bool
    let onSelect: () -> Void
    let onPlayAudio: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            selectButton
            audioButton
        }
    }

    private var selectButton: some View {
        Button(action: onSelect) {
            HStack {
                Text(option)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.headline)
                }
            }
        }
        .buttonStyle(
            OptionChipStyle(isSelected: isSelected, highContrast: highContrast)
        )
        .disabled(isLocked)
        .accessibilityLabel("Option: \(option)")
        .accessibilityHint(isSelected ? "Selected" : "Tap to select this response")
    }

    private var audioButton: some View {
        let bgFill = highContrast ? Color.black.opacity(0.58) : Color.white.opacity(0.82)
        let borderStroke = highContrast ? Color.white.opacity(0.85) : Color.white.opacity(0.55)

        return Button(action: onPlayAudio) {
            Image(systemName: "speaker.wave.1.fill")
                .font(.subheadline.weight(.semibold))
                .frame(width: 36, height: 36)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Play audio for \(option)")
        .accessibilityHint("Hear this option spoken aloud")
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(bgFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(borderStroke, lineWidth: 1)
        )
    }
}
