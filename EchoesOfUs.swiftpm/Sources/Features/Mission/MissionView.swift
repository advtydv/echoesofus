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
                let languageName = appState.languagePacks.first(where: { $0.id == mission.languageID })?.name ?? mission.languageID

                VStack(alignment: .leading, spacing: 10) {
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

                    Text("Audio source: \(appState.lastAudioPlaybackLabel)")
                        .font(.footnote)
                        .foregroundStyle(palette.cardSubtext)

                    Text("Use what you practiced in mastery sprint: meaning + respectful context.")
                        .font(.footnote)
                        .foregroundStyle(palette.cardSubtext)
                }
                .echoCard(highContrast: appState.learnerProfile.highContrast)

                VStack(spacing: 10) {
                    ForEach(Array(mission.options.enumerated()), id: \.offset) { index, option in
                        HStack(spacing: 8) {
                            Button {
                                shownHint = nil
                                appState.submitMissionOption(option)
                            } label: {
                                HStack {
                                    Text(option)
                                    Spacer()
                                    if appState.selectedMissionOption == option {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.headline)
                                    }
                                }
                            }
                            .buttonStyle(
                                OptionChipStyle(
                                    isSelected: appState.selectedMissionOption == option,
                                    highContrast: appState.learnerProfile.highContrast
                                )
                            )
                            .disabled(appState.missionResult == .correct)

                            Button {
                                appState.playMissionOptionAudio(mission: mission, optionIndex: index, optionText: option)
                            } label: {
                                Image(systemName: "speaker.wave.1.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(width: 36, height: 36)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(appState.learnerProfile.highContrast ? Color.black.opacity(0.58) : Color.white.opacity(0.82))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(appState.learnerProfile.highContrast ? Color.white.opacity(0.85) : Color.white.opacity(0.55), lineWidth: 1)
                            )
                        }
                    }
                }

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

                        Button(appState.missionIndex < appState.missions.count - 1 ? "Next mission" : "Continue to fairness lab") {
                            shownHint = nil
                            appState.goToNextMissionOrFinish()
                        }
                        .buttonStyle(PrimaryActionButton(highContrast: appState.learnerProfile.highContrast))
                    }
                    .echoCard(highContrast: appState.learnerProfile.highContrast)
                }
            } else {
                Text("No mission data available.")
                    .foregroundStyle(palette.cardText)
                    .echoCard(highContrast: appState.learnerProfile.highContrast)

                Button("Continue") {
                    appState.advanceStep()
                }
                .buttonStyle(PrimaryActionButton(highContrast: appState.learnerProfile.highContrast))
            }
        }
    }
}
