import SwiftUI

struct LearnView: View {
    @EnvironmentObject private var appState: AppState
    @State private var activeSyllableIndex: Int = 0
    @State private var showPronunciationSupport = false

    var body: some View {
        let palette = appState.learnerProfile.palette

        return StageShell(
            title: "Learn Core Phrases",
            subtitle: "Explore phrases with audio and pronunciation support."
        ) {
            if appState.languagePacks.isEmpty {
                Text("No language packs available.")
                    .foregroundStyle(palette.cardText)
                    .echoCard(highContrast: appState.learnerProfile.highContrast)
            } else {
                learnModePicker

                if appState.learnMode == .guidedDeck {
                    guidedDeckContent
                } else {
                    phraseLibraryContent
                }

                if appState.guidedMode == .judged {
                    Button("Continue to mastery sprint") {
                        appState.learnMode = .guidedDeck
                        appState.advanceStep()
                    }
                    .buttonStyle(PrimaryActionButton(highContrast: appState.learnerProfile.highContrast))
                    .padding(.top, 4)
                }
            }
        }
        .onChange(of: appState.currentPhrase?.id) { _, _ in
            activeSyllableIndex = 0
            showPronunciationSupport = false
        }
    }

    private var learnModePicker: some View {
        Picker("View", selection: $appState.learnMode) {
            ForEach(LearnMode.allCases) { mode in
                Text(mode.title).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    private var guidedDeckContent: some View {
        let palette = appState.learnerProfile.palette
        let hc = appState.learnerProfile.highContrast

        return VStack(alignment: .leading, spacing: 14) {
            if let phrase = appState.currentPhrase, let language = appState.currentLanguage {
                HStack {
                    Text(language.name)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(palette.cardSubtext)
                    Spacer()
                    Text(appState.phraseProgressLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(palette.cardSubtext)
                }

                Text(phrase.nativeText)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.cardText)

                Text(phrase.englishMeaning)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(palette.cardText)

                Button {
                    appState.playPhraseAudio(for: phrase)
                } label: {
                    Label("Play pronunciation", systemImage: "speaker.wave.2.fill")
                }
                .buttonStyle(SecondaryActionButton(highContrast: hc))
                .accessibilityLabel("Play pronunciation audio for \(phrase.nativeText)")

                DisclosureGroup(isExpanded: $showPronunciationSupport) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(phrase.phonetic)
                            .font(.body)
                            .foregroundStyle(palette.cardSubtext)

                        SyllableRow(
                            syllables: phrase.syllables,
                            activeIndex: activeSyllableIndex,
                            highContrast: hc
                        )

                        Button("Tap next beat") {
                            guard !phrase.syllables.isEmpty else { return }
                            activeSyllableIndex = (activeSyllableIndex + 1) % phrase.syllables.count
                        }
                        .buttonStyle(SecondaryActionButton(highContrast: hc))
                    }
                    .padding(.top, 8)
                } label: {
                    Text("Pronunciation helper")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(palette.cardText)
                }

                if appState.revealContextNote {
                    Text(phrase.contextNote)
                        .font(.footnote)
                        .foregroundStyle(palette.cardSubtext)
                        .padding(.top, 4)
                } else {
                    Button("Show cultural note") {
                        appState.revealContextNote = true
                    }
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(EchoTheme.clay)
                }

                phraseControls
            }
        }
        .echoCard(highContrast: hc)
    }

    private var phraseLibraryContent: some View {
        let palette = appState.learnerProfile.palette
        let phrases = appState.currentLanguage?.phrases ?? []
        let hc = appState.learnerProfile.highContrast

        return VStack(alignment: .leading, spacing: 10) {
            if phrases.isEmpty {
                Text("No phrases available.")
                    .font(.subheadline)
                    .foregroundStyle(palette.cardSubtext)
            } else {
                ForEach(phrases) { phrase in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(phrase.nativeText)
                                .font(.headline)
                            Text(phrase.englishMeaning)
                                .font(.caption)
                                .foregroundStyle(palette.cardSubtext)
                        }
                        Spacer()
                        Button {
                            appState.playPhraseAudio(for: phrase)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.subheadline)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(EchoTheme.clay)
                        .accessibilityLabel("Play \(phrase.nativeText)")
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .foregroundStyle(palette.cardText)
        .echoCard(highContrast: hc)
    }

    private var phraseControls: some View {
        let hc = appState.learnerProfile.highContrast

        return HStack(spacing: 10) {
            Button("Previous") {
                appState.previousPhrase()
            }
            .buttonStyle(SecondaryActionButton(highContrast: hc))
            .disabled(appState.phraseIndex == 0)
            .accessibilityLabel("Previous phrase")

            Button("Next") {
                appState.nextPhrase()
            }
            .buttonStyle(SecondaryActionButton(highContrast: hc))
            .disabled(isAtLastPhrase)
            .accessibilityLabel("Next phrase")
        }
    }

    private var isAtLastPhrase: Bool {
        guard let count = appState.currentLanguage?.phrases.count else { return true }
        return appState.phraseIndex >= max(0, count - 1)
    }
}
