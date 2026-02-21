import SwiftUI

struct LearningStudioView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLanguageID: String = ""

    var body: some View {
        let palette = appState.learnerProfile.palette

        return NavigationStack {
            ZStack {
                EchoBackdrop(
                    highContrast: appState.learnerProfile.highContrast,
                    focusMode: appState.learnerProfile.focusMode
                )

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Learning Studio")
                                .font(.largeTitle.weight(.bold))
                            Text("Explore mastery profile, weakest phrases, and category practice with offline audio support.")
                                .font(.subheadline)
                                .foregroundStyle(palette.backdropSubtext)
                        }
                        .foregroundStyle(palette.backdropText)

                        Picker("Language", selection: $selectedLanguageID) {
                            ForEach(appState.languagePacks) { pack in
                                Text(pack.name).tag(pack.id)
                            }
                        }
                        .pickerStyle(.segmented)
                        .echoCard(highContrast: appState.learnerProfile.highContrast)

                        practiceQueueSection

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Category Library")
                                .font(.headline)
                                .foregroundStyle(palette.cardText)

                            ForEach(PhraseCategory.allCases) { category in
                                let phrases = selectedLanguagePhrases.filter { $0.category == category }
                                if !phrases.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(category.displayName)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(palette.cardText)

                                        ForEach(phrases) { phrase in
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

                                                ConfidenceMeter(
                                                    confidence: appState.confidence(for: phrase.id),
                                                    highContrast: appState.learnerProfile.highContrast
                                                )
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
                    .padding(16)
                    .frame(maxWidth: 840)
                    .frame(maxWidth: .infinity, alignment: .top)
                }
            }
            .navigationTitle("Learning Studio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        if appState.route == .studio {
                            appState.goToDashboard()
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                if selectedLanguageID.isEmpty {
                    selectedLanguageID = appState.activeLanguageID
                }
            }
        }
    }

    private var selectedLanguagePhrases: [Phrase] {
        appState.phrases(for: selectedLanguageID)
    }

    private var practiceQueueSection: some View {
        let palette = appState.learnerProfile.palette
        let queue = appState.practiceQueue(for: selectedLanguageID)

        return VStack(alignment: .leading, spacing: 10) {
            Text("Practice Queue (Weakest First)")
                .font(.headline)
                .foregroundStyle(palette.cardText)

            if queue.isEmpty {
                Text("No practice queue yet. Complete a mastery sprint first.")
                    .font(.subheadline)
                    .foregroundStyle(palette.cardSubtext)
                    .echoCard(highContrast: appState.learnerProfile.highContrast)
            } else {
                ForEach(Array(queue.enumerated()), id: \.element.id) { index, phrase in
                    HStack(alignment: .top) {
                        Text("#\(index + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(palette.cardSubtext)
                            .frame(width: 28, alignment: .leading)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(phrase.nativeText)
                                .font(.headline)
                            Text(phrase.englishMeaning)
                                .font(.subheadline)
                                .foregroundStyle(palette.cardSubtext)
                        }

                        Spacer()

                        Text("\(Int((appState.confidence(for: phrase.id) * 100).rounded()))%")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(palette.cardText)
                    }
                    .echoCard(highContrast: appState.learnerProfile.highContrast)
                }
            }
        }
        .echoCard(highContrast: appState.learnerProfile.highContrast)
    }
}
