import SwiftUI

struct FairnessLabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var appeared = false

    var body: some View {
        StageShell(
            title: "What You Learned",
            subtitle: "A recap of the phrases and cultural knowledge you picked up today."
        ) {
            phrasesLearnedCard
            conversationCard
            culturalNotesCard

            Button("See your impact summary") {
                appState.advanceStep()
            }
            .buttonStyle(PrimaryActionButton(highContrast: appState.learnerProfile.highContrast))
            .padding(.top, 4)
        }
    }

    private var phrasesLearnedCard: some View {
        let palette = appState.learnerProfile.palette
        let hc = appState.learnerProfile.highContrast
        let phrases = appState.allPhrases

        return VStack(alignment: .leading, spacing: 12) {
            Label("Phrases explored", systemImage: "book.closed.fill")
                .font(.headline)
                .foregroundStyle(palette.cardText)

            if phrases.isEmpty {
                Text("No phrases loaded.")
                    .font(.subheadline)
                    .foregroundStyle(palette.cardSubtext)
            } else {
                ForEach(phrases.prefix(6)) { phrase in
                    PhraseRecapRow(phrase: phrase, palette: palette, hc: hc)
                }

                if phrases.count > 6 {
                    Text("+ \(phrases.count - 6) more phrases across all categories")
                        .font(.caption)
                        .foregroundStyle(palette.cardSubtext)
                }
            }
        }
        .echoCard(highContrast: hc)
    }

    private var conversationCard: some View {
        let palette = appState.learnerProfile.palette
        let hc = appState.learnerProfile.highContrast
        let fluency = appState.conversationFluencyScore
        let correct = appState.conversationCorrectCount

        return VStack(alignment: .leading, spacing: 12) {
            Label("Conversation practice", systemImage: "bubble.left.and.bubble.right")
                .font(.headline)
                .foregroundStyle(palette.cardText)

            if let conv = appState.currentConversation {
                Text(conv.scenarioTitle)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(palette.cardText)

                Text(conv.scenarioContext)
                    .font(.caption)
                    .foregroundStyle(palette.cardSubtext)
            }

            HStack(spacing: 16) {
                statBubble(value: "\(correct)", label: "correct", palette: palette, hc: hc)
                statBubble(value: "\(Int((fluency * 100).rounded()))%", label: "fluency", palette: palette, hc: hc)
                statBubble(value: "\(appState.completedMissions)", label: "missions", palette: palette, hc: hc)
            }
        }
        .echoCard(highContrast: hc)
    }

    private var culturalNotesCard: some View {
        let palette = appState.learnerProfile.palette
        let hc = appState.learnerProfile.highContrast
        let phrasesWithNotes = appState.allPhrases.filter { !$0.contextNote.isEmpty }.prefix(3)

        return VStack(alignment: .leading, spacing: 12) {
            Label("Cultural notes", systemImage: "globe.americas")
                .font(.headline)
                .foregroundStyle(palette.cardText)

            if phrasesWithNotes.isEmpty {
                Text("Explore phrases to uncover cultural context.")
                    .font(.subheadline)
                    .foregroundStyle(palette.cardSubtext)
            } else {
                ForEach(phrasesWithNotes) { phrase in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(phrase.nativeText)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(hc ? .white : EchoTheme.clay)
                        Text(phrase.contextNote)
                            .font(.caption)
                            .foregroundStyle(palette.cardSubtext)
                    }
                }
            }
        }
        .echoCard(highContrast: hc)
    }

    private func statBubble(value: String, label: String, palette: EchoPalette, hc: Bool) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(hc ? .white : EchoTheme.clay)
            Text(label)
                .font(.caption)
                .foregroundStyle(palette.cardSubtext)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(hc ? Color.white.opacity(0.08) : EchoTheme.cream)
        )
    }
}

private struct PhraseRecapRow: View {
    let phrase: Phrase
    let palette: EchoPalette
    let hc: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(phrase.nativeText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(hc ? .white : EchoTheme.clay)
                Text(phrase.englishMeaning)
                    .font(.caption)
                    .foregroundStyle(palette.cardSubtext)
            }
            Spacer()
            Text(phrase.phonetic)
                .font(.caption2)
                .foregroundStyle(palette.cardSubtext)
        }
    }
}
