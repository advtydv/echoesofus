import SwiftUI

struct InclusionSetupView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showAccessibility = false

    var body: some View {
        let palette = appState.learnerProfile.palette

        StageShell(
            title: "Choose a Language",
            subtitle: "Pick a language to begin learning."
        ) {
            VStack(spacing: 12) {
                languageSelector(palette: palette)

                if showAccessibility {
                    accessibilityToggles(palette: palette)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Button {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showAccessibility.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "accessibility")
                            .font(.subheadline)
                        Text(showAccessibility ? "Hide accessibility options" : "Accessibility options")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundStyle(palette.cardSubtext)
                }
                .buttonStyle(.plain)

                Button("Start learning") {
                    appState.advanceStep()
                }
                .buttonStyle(PrimaryActionButton(highContrast: appState.learnerProfile.highContrast))
                .padding(.top, 4)
            }
        }
    }

    private func languageSelector(palette: EchoPalette) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("Language", selection: $appState.activeLanguageID) {
                ForEach(appState.languagePacks) { pack in
                    Text(pack.name).tag(pack.id)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: appState.activeLanguageID) { _, newValue in
                appState.selectLanguage(newValue)
            }

            if let lang = appState.currentLanguage {
                HStack(spacing: 6) {
                    Image(systemName: "globe.americas")
                        .font(.caption)
                    Text(lang.region)
                        .font(.caption)
                }
                .foregroundStyle(palette.cardSubtext)
            }
        }
        .echoCard(highContrast: appState.learnerProfile.highContrast)
    }

    private func accessibilityToggles(palette: EchoPalette) -> some View {
        VStack(spacing: 2) {
            CompactToggle(title: "High contrast", isOn: $appState.learnerProfile.highContrast, palette: palette)
            CompactToggle(title: "Focus mode", isOn: $appState.learnerProfile.focusMode, palette: palette)
            CompactToggle(title: "Reading support", isOn: $appState.learnerProfile.readingSupport, palette: palette)
            CompactToggle(title: "Bilingual hints", isOn: $appState.learnerProfile.bilingualHints, palette: palette)
        }
        .echoCard(highContrast: appState.learnerProfile.highContrast)
    }
}

private struct CompactToggle: View {
    let title: String
    @Binding var isOn: Bool
    let palette: EchoPalette

    var body: some View {
        Toggle(title, isOn: $isOn)
            .font(.subheadline)
            .foregroundStyle(palette.cardText)
            .tint(EchoTheme.clay)
            .padding(.vertical, 8)
    }
}
