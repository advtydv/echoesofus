import SwiftUI

struct IntroView: View {
    @EnvironmentObject private var appState: AppState
    @State private var phase: IntroPhase = .waiting
    @State private var line1: String = ""
    @State private var line2: String = ""
    @State private var showEchoPhrase = false
    @State private var showMeaning = false
    @State private var showPillars = false
    @State private var showButton = false

    private let fullLine1 = "Every two weeks, a language falls silent."
    private let fullLine2 = "With it, generations of knowledge disappear."

    var body: some View {
        let hc = appState.learnerProfile.highContrast

        GeometryReader { geo in
            ZStack {
                (hc ? EchoTheme.strongBackground : EchoTheme.background)
                    .ignoresSafeArea()

                ambientShapes
                    .opacity(phase.rawValue >= IntroPhase.echoPhrase.rawValue ? 0.6 : 0)

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        if !showButton {
                            Button {
                                appState.advanceStep()
                            } label: {
                                Text("Skip")
                                    .font(.footnote.weight(.medium))
                                    .foregroundStyle(hc ? .white.opacity(0.7) : EchoTheme.night.opacity(0.5))
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 14)
                                    .background(
                                        Capsule(style: .continuous)
                                            .fill(hc ? Color.white.opacity(0.12) : Color.white.opacity(0.4))
                                    )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Skip intro")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .frame(height: 44)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Spacer(minLength: geo.size.height * 0.10)

                            VStack(alignment: .center, spacing: 24) {
                                if !line1.isEmpty {
                                    Text(line1)
                                        .font(.title2.weight(.semibold))
                                        .foregroundStyle(hc ? .white.opacity(0.92) : EchoTheme.night.opacity(0.88))
                                        .multilineTextAlignment(.center)
                                        .accessibilityLabel(fullLine1)
                                }

                                if !line2.isEmpty {
                                    Text(line2)
                                        .font(.title3.weight(.medium))
                                        .foregroundStyle(hc ? .white.opacity(0.78) : EchoTheme.night.opacity(0.65))
                                        .multilineTextAlignment(.center)
                                        .accessibilityLabel(fullLine2)
                                }

                                if showEchoPhrase {
                                    VStack(spacing: 12) {
                                        Text("Yá'át'ééh")
                                            .font(.system(size: 44, weight: .bold, design: .rounded))
                                            .foregroundStyle(hc ? .white : EchoTheme.clay)
                                            .shadow(color: EchoTheme.clay.opacity(0.4), radius: 20, x: 0, y: 0)
                                            .scaleEffect(showEchoPhrase ? 1 : 0.7)

                                        if showMeaning {
                                            Text("\"Hello / It is good\" — Diné Bizaad (Navajo)")
                                                .font(.subheadline.weight(.medium))
                                                .foregroundStyle(hc ? .white.opacity(0.72) : EchoTheme.night.opacity(0.55))
                                                .transition(.opacity.combined(with: .offset(y: 8)))
                                        }
                                    }
                                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                                    .padding(.vertical, 16)
                                }

                                if showPillars {
                                    VStack(alignment: .leading, spacing: 14) {
                                        pillarRow(icon: "heart.text.square", text: "Preserve language dignity")
                                        pillarRow(icon: "cpu", text: "Support equitable AI outcomes")
                                        pillarRow(icon: "book.pages", text: "Provide inclusive classroom tools")
                                    }
                                    .transition(.opacity.combined(with: .offset(y: 14)))
                                }

                                if showButton {
                                    Button("Begin the journey") {
                                        appState.advanceStep()
                                    }
                                    .buttonStyle(PrimaryActionButton(highContrast: hc))
                                    .transition(.opacity.combined(with: .offset(y: 10)))
                                    .padding(.top, 8)
                                }
                            }
                            .padding(.horizontal, 24)
                            .frame(maxWidth: 600)
                            .readableText(appState.learnerProfile.readingSupport)

                            Spacer(minLength: geo.size.height * 0.12)
                        }
                        .frame(minHeight: geo.size.height - 44)
                    }
                }
            }
        }
        .onAppear {
            if appState.learnerProfile.focusMode {
                showAllImmediate()
            } else {
                startCinematicSequence()
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Introduction: Why language preservation matters")
    }

    private func pillarRow(icon: String, text: String) -> some View {
        let hc = appState.learnerProfile.highContrast
        return HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(EchoTheme.clay)
                .frame(width: 28)
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(hc ? .white.opacity(0.88) : EchoTheme.night.opacity(0.75))
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var ambientShapes: some View {
        if !appState.learnerProfile.focusMode {
            ZStack {
                Circle()
                    .fill(EchoTheme.clay.opacity(0.15))
                    .frame(width: 220, height: 220)
                    .blur(radius: 30)
                    .offset(x: -100, y: -180)

                Circle()
                    .fill(EchoTheme.moss.opacity(0.12))
                    .frame(width: 180, height: 180)
                    .blur(radius: 24)
                    .offset(x: 120, y: 200)
            }
        }
    }

    private func showAllImmediate() {
        phase = .ready
        line1 = fullLine1
        line2 = fullLine2
        showEchoPhrase = true
        showMeaning = true
        showPillars = true
        showButton = true
    }

    private func startCinematicSequence() {
        Task { @MainActor in
            withAnimation(.easeIn(duration: 0.4)) {
                phase = .typing1
            }

            try? await Task.sleep(for: .milliseconds(400))

            for char in fullLine1 {
                line1.append(char)
                try? await Task.sleep(for: .milliseconds(38))
            }

            try? await Task.sleep(for: .milliseconds(800))
            phase = .typing2

            for char in fullLine2 {
                line2.append(char)
                try? await Task.sleep(for: .milliseconds(38))
            }

            try? await Task.sleep(for: .milliseconds(900))
            phase = .echoPhrase

            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showEchoPhrase = true
            }

            try? await Task.sleep(for: .milliseconds(600))

            withAnimation(.easeOut(duration: 0.5)) {
                showMeaning = true
            }

            try? await Task.sleep(for: .milliseconds(800))
            phase = .pillars

            withAnimation(.easeOut(duration: 0.5)) {
                showPillars = true
            }

            try? await Task.sleep(for: .milliseconds(500))
            phase = .ready

            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showButton = true
            }
        }
    }
}

private enum IntroPhase: Int {
    case waiting = 0
    case typing1 = 1
    case typing2 = 2
    case echoPhrase = 3
    case pillars = 4
    case ready = 5
}
