import SwiftUI

struct IntroView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        let palette = appState.learnerProfile.palette

        return StageShell(
            title: "Why This Matters",
            subtitle: "Language inclusion is essential for equal opportunity in education and AI."
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Students who speak low-resource languages are often underserved by mainstream learning technology.")
                    .font(.title3.weight(.semibold))
                Text("Echoes of Us demonstrates a practical path: accessible learning design, culturally respectful phrase practice, and transparent AI fairness concepts in one offline classroom-ready experience.")
                    .font(.body)
                    .readableText(appState.learnerProfile.readingSupport)
            }
            .foregroundStyle(palette.cardText)
            .echoCard(highContrast: appState.learnerProfile.highContrast)

            VStack(alignment: .leading, spacing: 8) {
                Label("Preserve language dignity", systemImage: "heart.text.square")
                Label("Support equitable AI outcomes", systemImage: "cpu")
                Label("Provide inclusive classroom tools", systemImage: "book.pages")
            }
            .font(.subheadline)
            .foregroundStyle(palette.cardText)
            .echoCard(highContrast: appState.learnerProfile.highContrast)

            Button("Continue to inclusion setup") {
                appState.advanceStep()
            }
            .buttonStyle(PrimaryActionButton(highContrast: appState.learnerProfile.highContrast))
        }
    }
}
