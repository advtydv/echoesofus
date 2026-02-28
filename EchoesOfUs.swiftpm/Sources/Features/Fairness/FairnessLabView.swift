import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct FairnessLabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        let palette = appState.learnerProfile.palette

        return StageShell(
            title: "AI Fairness Lab",
            subtitle: "See why community contribution has outsized effects on low-resource language outcomes."
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Community contributions")
                    .font(.headline)
                    .foregroundStyle(palette.cardText)

                Slider(value: $appState.contributionAmount, in: 0...100, step: 1)
                    .tint(EchoTheme.clay)

                Text("\(Int(appState.contributionAmount)) contribution units")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(palette.cardSubtext)
            }
            .echoCard(highContrast: appState.learnerProfile.highContrast)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) {
                    scorePill(title: "Low-resource", value: appState.lowResourceScore, icon: "waveform.path.ecg")
                    scorePill(title: "High-resource", value: appState.highResourceScore, icon: "chart.bar.fill")
                }
                VStack(alignment: .leading, spacing: 10) {
                    scorePill(title: "Low-resource", value: appState.lowResourceScore, icon: "waveform.path.ecg")
                    scorePill(title: "High-resource", value: appState.highResourceScore, icon: "chart.bar.fill")
                }
            }

            chartBlock
                .echoCard(highContrast: appState.learnerProfile.highContrast)

            VStack(alignment: .leading, spacing: 8) {
                Text("Low-resource score = min(82, 54 + c * 0.28)")
                Text("High-resource score = min(96, 92 + c * 0.05)")
                Text("Equivalent effort lifts low-resource outcomes much faster, which is why inclusive data strategy matters.")
            }
            .font(.footnote)
            .foregroundStyle(palette.cardSubtext)
            .echoCard(highContrast: appState.learnerProfile.highContrast)

            Button("View impact summary") {
                appState.advanceStep()
            }
            .buttonStyle(PrimaryActionButton(highContrast: appState.learnerProfile.highContrast))
        }
    }

    @ViewBuilder
    private var chartBlock: some View {
#if canImport(Charts)
        Chart(scoreRows) { row in
            BarMark(
                x: .value("Model Readiness", row.score),
                y: .value("Language Resource Tier", row.label)
            )
            .foregroundStyle(row.color.gradient)
            .cornerRadius(6)
        }
        .chartXScale(domain: 0...100)
        .chartLegend(.hidden)
        .frame(height: 190)
#else
        let palette = appState.learnerProfile.palette

        VStack(spacing: 12) {
            ForEach(scoreRows) { row in
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(row.label): \(Int(row.score))")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(palette.cardText)
                    GeometryReader { geometry in
                        let width = max(4, geometry.size.width * (row.score / 100.0))
                        RoundedRectangle(cornerRadius: 8)
                            .fill(row.color)
                            .frame(width: width, height: 16)
                    }
                    .frame(height: 16)
                }
            }
        }
        .frame(height: 130)
#endif
    }

    private var scoreRows: [ScoreRow] {
        [
            ScoreRow(label: "Low-resource languages", score: appState.lowResourceScore, color: EchoTheme.clay),
            ScoreRow(label: "High-resource languages", score: appState.highResourceScore, color: EchoTheme.moss)
        ]
    }

    private func scorePill(title: String, value: Double, icon: String) -> some View {
        let palette = appState.learnerProfile.palette

        return VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
            Text(String(format: "%.1f", value))
                .font(.title2.weight(.bold))
        }
        .foregroundStyle(palette.cardText)
        .frame(maxWidth: .infinity, alignment: .leading)
        .echoCard(highContrast: appState.learnerProfile.highContrast)
    }
}

private struct ScoreRow: Identifiable {
    var id: String { label }
    let label: String
    let score: Double
    let color: Color
}
