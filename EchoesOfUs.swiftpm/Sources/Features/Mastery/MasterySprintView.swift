import SwiftUI

struct MasterySprintView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showPronunciationSupport = false
    @State private var activeSyllableIndex = 0

    var body: some View {
        let palette = appState.learnerProfile.palette

        return StageShell(
            title: "Mastery Sprint",
            subtitle: "Answer adaptive prompts, review, then submit once for final scoring."
        ) {
            if let prompt = appState.currentSprintPrompt {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        InlineBadge(
                            title: "Prompt \(appState.sprintProgressLabel)",
                            systemImage: "target",
                            highContrast: appState.learnerProfile.highContrast
                        )
                        Spacer()
                        InlineBadge(
                            title: "Answered \(appState.sprintAnsweredCount)/\(appState.currentSprintPrompts.count)",
                            systemImage: "checkmark.circle",
                            highContrast: appState.learnerProfile.highContrast
                        )
                    }

                    Text(prompt.prompt)
                        .font(.title3.weight(.semibold))
                        .readableText(appState.learnerProfile.readingSupport)
                        .foregroundStyle(palette.cardText)

                    ConfidenceMeter(
                        confidence: appState.confidence(for: prompt.phraseID),
                        highContrast: appState.learnerProfile.highContrast
                    )
                }
                .echoCard(highContrast: appState.learnerProfile.highContrast)

                promptNavigator

                VStack(spacing: 10) {
                    ForEach(prompt.options, id: \.self) { option in
                        Button {
                            appState.setSprintResponse(promptID: prompt.id, option: option)
                        } label: {
                            HStack {
                                Text(option)
                                Spacer()
                                if appState.currentSprintSelectedOption == option {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                        }
                        .buttonStyle(
                            OptionChipStyle(
                                isSelected: appState.currentSprintSelectedOption == option,
                                highContrast: appState.learnerProfile.highContrast
                            )
                        )
                        .disabled(appState.isSprintSubmitted)
                        .accessibilityLabel("Option: \(option)")
                        .accessibilityHint(appState.currentSprintSelectedOption == option ? "Selected" : "Tap to select")
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    if let phrase = appState.allPhrases.first(where: { $0.id == prompt.phraseID }) {
                        Button {
                            appState.playPhraseAudio(for: phrase)
                        } label: {
                            Label("Play phrase audio", systemImage: "speaker.wave.2.fill")
                        }
                        .buttonStyle(SecondaryActionButton(highContrast: appState.learnerProfile.highContrast))
                        .accessibilityLabel("Play audio for this phrase")
                        .accessibilityHint("Plays native clip or helper narration")

                        Text("Audio source: \(appState.lastAudioPlaybackLabel)")
                            .font(.footnote)
                            .foregroundStyle(palette.cardSubtext)
                    }

                    DisclosureGroup(isExpanded: $showPronunciationSupport) {
                        VStack(alignment: .leading, spacing: 8) {
                            SyllableRow(
                                syllables: prompt.syllables,
                                activeIndex: activeSyllableIndex,
                                highContrast: appState.learnerProfile.highContrast
                            )

                            Button("Tap next beat") {
                                guard !prompt.syllables.isEmpty else { return }
                                activeSyllableIndex = (activeSyllableIndex + 1) % prompt.syllables.count
                            }
                            .buttonStyle(SecondaryActionButton(highContrast: appState.learnerProfile.highContrast))

                            Text("Support mode can help pacing, and submitted grading accounts for support usage.")
                                .font(.footnote)
                                .foregroundStyle(palette.cardSubtext)
                        }
                        .padding(.top, 8)
                    } label: {
                        Text("Pronunciation support")
                            .font(.headline)
                            .foregroundStyle(palette.cardText)
                    }
                    .onChange(of: showPronunciationSupport) { _, newValue in
                        if newValue {
                            appState.markSprintSupportUsed()
                        }
                    }
                }
                .echoCard(highContrast: appState.learnerProfile.highContrast)

                HStack(spacing: 10) {
                    Button("Previous") {
                        appState.goToPreviousSprintPrompt()
                    }
                    .buttonStyle(SecondaryActionButton(highContrast: appState.learnerProfile.highContrast))
                    .disabled(appState.sprintIndex == 0 || appState.isSprintSubmitted)

                    Button("Next") {
                        appState.goToNextSprintPrompt()
                    }
                    .buttonStyle(SecondaryActionButton(highContrast: appState.learnerProfile.highContrast))
                    .disabled(appState.sprintIndex >= appState.currentSprintPrompts.count - 1 || appState.isSprintSubmitted)
                }

                if appState.isSprintSubmitted {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Sprint scored", systemImage: "checkmark.seal.fill")
                            .font(.headline)
                            .foregroundStyle(palette.cardText)

                        Text(appState.sprintFeedback ?? "")
                            .font(.subheadline)
                            .foregroundStyle(palette.cardSubtext)

                        Button("Continue to mission") {
                            appState.advanceStep()
                        }
                        .buttonStyle(PrimaryActionButton(highContrast: appState.learnerProfile.highContrast))
                    }
                    .echoCard(highContrast: appState.learnerProfile.highContrast)
                } else {
                    Button("Submit sprint") {
                        appState.submitSprint()
                    }
                    .buttonStyle(PrimaryActionButton(highContrast: appState.learnerProfile.highContrast))
                    .disabled(appState.sprintAnsweredCount < appState.currentSprintPrompts.count)
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Preparing adaptive prompts...")
                        .font(.headline)
                        .foregroundStyle(palette.cardText)
                    Text("Tap reload to regenerate the sprint.")
                        .font(.subheadline)
                        .foregroundStyle(palette.cardSubtext)
                }
                .echoCard(highContrast: appState.learnerProfile.highContrast)

                Button("Reload sprint") {
                    appState.startMasterySprint()
                }
                .buttonStyle(SecondaryActionButton(highContrast: appState.learnerProfile.highContrast))
            }
        }
        .onAppear {
            if appState.currentSprintPrompts.isEmpty {
                appState.startMasterySprint()
            }
        }
        .onChange(of: appState.currentSprintPrompt?.id) { _, _ in
            showPronunciationSupport = false
            activeSyllableIndex = 0
        }
    }

    private var promptNavigator: some View {
        let palette = appState.learnerProfile.palette

        return VStack(alignment: .leading, spacing: 8) {
            Text("Prompt navigator")
                .font(.caption.weight(.semibold))
                .foregroundStyle(palette.cardSubtext)

            HStack(spacing: 8) {
                ForEach(Array(appState.currentSprintPrompts.enumerated()), id: \.element.id) { index, prompt in
                    Button {
                        appState.sprintIndex = index
                    } label: {
                        HStack(spacing: 4) {
                            Text("\(index + 1)")
                            if appState.sprintResponsesByPromptID[prompt.id] != nil {
                                Image(systemName: "checkmark")
                                    .font(.caption2)
                            }
                        }
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(chipTextColor(index: index))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            Capsule(style: .continuous)
                                .fill(chipBackgroundColor(index: index))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(appState.isSprintSubmitted)
                }
            }
        }
        .echoCard(highContrast: appState.learnerProfile.highContrast)
    }

    private func chipBackgroundColor(index: Int) -> Color {
        if appState.learnerProfile.highContrast {
            return index == appState.sprintIndex ? Color.white : Color.black.opacity(0.55)
        }
        return index == appState.sprintIndex ? EchoTheme.clay : Color.white.opacity(0.78)
    }

    private func chipTextColor(index: Int) -> Color {
        if appState.learnerProfile.highContrast {
            return index == appState.sprintIndex ? EchoTheme.night : Color.white
        }
        return index == appState.sprintIndex ? Color.white : EchoTheme.night
    }
}
