import SwiftUI

struct LearnView: View {
    @EnvironmentObject private var appState: AppState
    @State private var activeSyllableIndex: Int = 0
    @State private var showPronunciationSupport = false

    var body: some View {
        let palette = appState.learnerProfile.palette

        return StageShell(
            title: "Learn Core Phrases",
            subtitle: "Use guided learning or full library browsing with offline audio support."
        ) {
            if appState.languagePacks.isEmpty {
                Text("No language packs available.")
                    .foregroundStyle(palette.cardText)
                    .echoCard(highContrast: appState.learnerProfile.highContrast)
            } else {
                languagePicker
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
                    .padding(.top, 8)
                }
            }
        }
        .onChange(of: appState.currentPhrase?.id) { _, _ in
            activeSyllableIndex = 0
            showPronunciationSupport = false
        }
    }

    private var languagePicker: some View {
        let palette = appState.learnerProfile.palette

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Language")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.backdropSubtext)
                Spacer()
                if let region = appState.currentLanguage?.region {
                    InlineBadge(
                        title: region,
                        systemImage: "globe.americas",
                        highContrast: appState.learnerProfile.highContrast
                    )
                }
            }

            Picker("Language", selection: $appState.activeLanguageID) {
                ForEach(appState.languagePacks) { pack in
                    Text(pack.name).tag(pack.id)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: appState.activeLanguageID) { _, newValue in
                appState.selectLanguage(newValue)
            }
        }
    }

    private var learnModePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Learning view")
                .font(.caption.weight(.semibold))
                .foregroundStyle(appState.learnerProfile.palette.backdropSubtext)

            Picker("Learning view", selection: $appState.learnMode) {
                ForEach(LearnMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var guidedDeckContent: some View {
        let palette = appState.learnerProfile.palette

        return VStack(alignment: .leading, spacing: 14) {
            if let phrase = appState.currentPhrase, let language = appState.currentLanguage {
                HStack {
                    Text(language.name)
                        .font(.headline)
                    Spacer()
                    Text(appState.phraseProgressLabel)
                        .font(.footnote.weight(.semibold))
                }
                .foregroundStyle(palette.cardText)

                Text(phrase.nativeText)
                    .font(.system(size: appState.learnerProfile.readingSupport ? 36 : 32, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.cardText)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Meaning")
                        .font(.caption.weight(.semibold))
                    Text(phrase.englishMeaning)
                        .font(.title3.weight(.medium))
                }
                .foregroundStyle(palette.cardText)

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) {
                        InlineBadge(
                            title: phrase.category.displayName,
                            systemImage: "square.stack.3d.up",
                            highContrast: appState.learnerProfile.highContrast
                        )
                        InlineBadge(
                            title: phrase.formality.displayName,
                            systemImage: "person.text.rectangle",
                            highContrast: appState.learnerProfile.highContrast
                        )
                        InlineBadge(
                            title: "Difficulty \(phrase.difficulty)/5",
                            systemImage: "chart.line.uptrend.xyaxis",
                            highContrast: appState.learnerProfile.highContrast
                        )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        InlineBadge(
                            title: phrase.category.displayName,
                            systemImage: "square.stack.3d.up",
                            highContrast: appState.learnerProfile.highContrast
                        )
                        InlineBadge(
                            title: phrase.formality.displayName,
                            systemImage: "person.text.rectangle",
                            highContrast: appState.learnerProfile.highContrast
                        )
                        InlineBadge(
                            title: "Difficulty \(phrase.difficulty)/5",
                            systemImage: "chart.line.uptrend.xyaxis",
                            highContrast: appState.learnerProfile.highContrast
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        appState.playPhraseAudio(for: phrase)
                    } label: {
                        Label("Play pronunciation", systemImage: "speaker.wave.2.fill")
                    }
                    .buttonStyle(SecondaryActionButton(highContrast: appState.learnerProfile.highContrast))
                    .accessibilityLabel("Play pronunciation audio for \(phrase.nativeText)")
                    .accessibilityHint("Plays native clip or helper narration")

                    Text("Audio source: \(appState.lastAudioPlaybackLabel)")
                        .font(.footnote)
                        .foregroundStyle(palette.cardSubtext)
                    Text("Uses native clip if available. Otherwise, helper narration is generated offline.")
                        .font(.footnote)
                        .foregroundStyle(palette.cardSubtext)
                }
                .echoCard(highContrast: appState.learnerProfile.highContrast)

                DisclosureGroup(isExpanded: $showPronunciationSupport) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phonetic")
                            .font(.caption.weight(.semibold))
                        Text(phrase.phonetic)
                            .font(.body)
                            .foregroundStyle(palette.cardSubtext)

                        SyllableRow(
                            syllables: phrase.syllables,
                            activeIndex: activeSyllableIndex,
                            highContrast: appState.learnerProfile.highContrast
                        )

                        Button("Tap next beat") {
                            guard !phrase.syllables.isEmpty else { return }
                            activeSyllableIndex = (activeSyllableIndex + 1) % phrase.syllables.count
                        }
                        .buttonStyle(SecondaryActionButton(highContrast: appState.learnerProfile.highContrast))
                    }
                    .padding(.top, 8)
                } label: {
                    Text("Pronunciation helper")
                        .font(.headline)
                        .foregroundStyle(palette.cardText)
                }
                .echoCard(highContrast: appState.learnerProfile.highContrast)

                if appState.revealContextNote {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Cultural note")
                            .font(.caption.weight(.semibold))
                        Text(phrase.contextNote)
                            .font(.body)
                    }
                    .foregroundStyle(palette.cardText)
                    .echoCard(highContrast: appState.learnerProfile.highContrast)
                } else {
                    Button("Reveal cultural note") {
                        appState.revealContextNote = true
                    }
                    .buttonStyle(SecondaryActionButton(highContrast: appState.learnerProfile.highContrast))
                }

                phraseControls
            }
        }
        .echoCard(highContrast: appState.learnerProfile.highContrast)
    }

    private var phraseLibraryContent: some View {
        let palette = appState.learnerProfile.palette
        let phrases = appState.currentLanguage?.phrases ?? []

        return VStack(alignment: .leading, spacing: 10) {
            Text("Library")
                .font(.headline)
                .foregroundStyle(palette.cardText)

            if phrases.isEmpty {
                Text("No phrases available for this language.")
                    .font(.subheadline)
                    .foregroundStyle(palette.cardSubtext)
            } else {
                ForEach(PhraseCategory.allCases) { category in
                    let categoryPhrases = phrases.filter { $0.category == category }
                    if !categoryPhrases.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category.displayName)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(palette.cardText)

                            ForEach(categoryPhrases) { phrase in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(phrase.nativeText)
                                                .font(.headline)
                                            Text(phrase.englishMeaning)
                                                .font(.subheadline)
                                                .foregroundStyle(palette.cardSubtext)
                                        }
                                        Spacer()
                                        InlineBadge(
                                            title: phrase.formality.displayName,
                                            systemImage: "person.text.rectangle",
                                            highContrast: appState.learnerProfile.highContrast
                                        )
                                    }

                                    Text("Phonetic: \(phrase.phonetic)")
                                        .font(.footnote)
                                        .foregroundStyle(palette.cardSubtext)

                                    Button {
                                        appState.playPhraseAudio(for: phrase)
                                    } label: {
                                        Label("Play audio", systemImage: "speaker.wave.2.fill")
                                    }
                                    .buttonStyle(SecondaryActionButton(highContrast: appState.learnerProfile.highContrast))
                                    .accessibilityLabel("Play audio for \(phrase.nativeText)")
                                    .accessibilityHint("Plays native clip or helper narration")
                                }
                                .echoCard(highContrast: appState.learnerProfile.highContrast)
                            }
                        }
                        .echoCard(highContrast: appState.learnerProfile.highContrast)
                    }
                }

                Text("Last audio source: \(appState.lastAudioPlaybackLabel)")
                    .font(.footnote)
                    .foregroundStyle(palette.cardSubtext)
                    .echoCard(highContrast: appState.learnerProfile.highContrast)
            }
        }
        .echoCard(highContrast: appState.learnerProfile.highContrast)
    }

    private var phraseControls: some View {
        HStack(spacing: 10) {
            Button("Previous") {
                appState.previousPhrase()
            }
            .buttonStyle(SecondaryActionButton(highContrast: appState.learnerProfile.highContrast))
            .disabled(appState.phraseIndex == 0)
            .accessibilityLabel("Previous phrase")
            .accessibilityHint("Go to the previous phrase card")

            Button("Next") {
                appState.nextPhrase()
            }
            .buttonStyle(SecondaryActionButton(highContrast: appState.learnerProfile.highContrast))
            .disabled(isAtLastPhrase)
            .accessibilityLabel("Next phrase")
            .accessibilityHint("Go to the next phrase card")
        }
    }

    private var isAtLastPhrase: Bool {
        guard let count = appState.currentLanguage?.phrases.count else { return true }
        return appState.phraseIndex >= max(0, count - 1)
    }
}
