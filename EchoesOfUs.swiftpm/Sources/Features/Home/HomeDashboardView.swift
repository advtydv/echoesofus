import SwiftUI
import UIKit

struct HomeDashboardView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        let hc = appState.learnerProfile.highContrast

        GeometryReader { geo in
            ZStack {
                // Full-screen background — raw .jpg in bundle, must load via BundleResourceFinder
                if !hc, let url = BundleResourceFinder.url(forResource: "hero_banner", withExtension: "jpg"),
                   let uiImg = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: uiImg)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .ignoresSafeArea()
                } else {
                    EchoTheme.sand.ignoresSafeArea()
                }

                // Darkening scrim
                LinearGradient(
                    colors: [
                        Color.black.opacity(hc ? 0.6 : 0.12),
                        Color.black.opacity(hc ? 0.7 : 0.45)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Fireflies
                if !appState.learnerProfile.focusMode && !hc {
                    FireflyHeader(highContrast: false)
                        .frame(width: geo.size.width, height: geo.size.height)
                }

                // Content: title centered in top two-thirds, tiles pinned to bottom
                VStack(spacing: 0) {
                    Spacer(minLength: 0).frame(maxHeight: .infinity)
                    titleSection(hc: hc)
                    Spacer(minLength: 0).frame(maxHeight: .infinity)
                    tilesSection(hc: hc)
                        .padding(.bottom, geo.safeAreaInsets.bottom + 16)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
    }

    // MARK: - Title

    private func titleSection(hc: Bool) -> some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text("Echoes of Us")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 6, y: 2)
                Text("Preserve language. Promote equity.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 1)
            }
            .multilineTextAlignment(.center)

            Button(action: { appState.startGuidedJourney() }) {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill").font(.subheadline.weight(.semibold))
                    Text("Start Guided Journey").font(.headline)
                }
                .foregroundStyle(hc ? EchoTheme.night : .white)
                .frame(maxWidth: 300)
                .padding(.vertical, 15)
                .background(
                    Capsule(style: .continuous)
                        .fill(hc
                            ? AnyShapeStyle(Color.white)
                            : AnyShapeStyle(LinearGradient(
                                colors: [EchoTheme.clay, EchoTheme.clayDark],
                                startPoint: .leading, endPoint: .trailing))
                        )
                )
                .shadow(color: EchoTheme.clay.opacity(hc ? 0 : 0.45), radius: 16, y: 6)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }

    // MARK: - Tiles

    private func tilesSection(hc: Bool) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Activities")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))
                .padding(.leading, 2)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                HomeTile(icon: "book.closed.fill", label: "Learn", description: "Browse phrases", color: EchoTheme.clay, hc: hc) {
                    appState.prepareQuickAccess(step: .learn)
                }
                HomeTile(icon: "target", label: "Practice", description: "Mastery sprint", color: EchoTheme.moss, hc: hc) {
                    appState.prepareQuickAccess(step: .mastery)
                }
                HomeTile(icon: "checkmark.message.fill", label: "Missions", description: "Real scenarios", color: Color(red: 0.45, green: 0.40, blue: 0.70), hc: hc) {
                    appState.prepareQuickAccess(step: .mission)
                }
                HomeTile(icon: "bubble.left.and.bubble.right", label: "Talk", description: "Conversation sim", color: Color(red: 0.22, green: 0.53, blue: 0.67), hc: hc) {
                    appState.prepareQuickAccess(step: .conversation)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
}

// MARK: - Activity Tile

private struct HomeTile: View {
    let icon: String
    let label: String
    let description: String
    let color: Color
    let hc: Bool
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.25))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(hc ? .white : color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.18), radius: 10, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(pressed ? 0.96 : 1)
        .animation(.easeOut(duration: 0.12), value: pressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
        .accessibilityLabel(label)
        .accessibilityHint(description)
    }
}

// MARK: - Firefly Header

private struct FireflyHeader: View {
    let highContrast: Bool

    // 20 particles with seeded random properties
    private let particles: [Particle] = {
        let colors: [Color] = [
            EchoTheme.clay,
            EchoTheme.moss,
            EchoTheme.sky,
            EchoTheme.dawn,
            EchoTheme.sand,
        ]
        var rng = SeededRNG(seed: 42)
        return (0..<20).map { i in
            Particle(
                id: i,
                xFraction: rng.next(),
                yFraction: rng.next(),
                size: 3.5 + rng.next() * 4.5,
                color: colors[i % colors.count],
                driftX: (rng.next() - 0.5) * 40,
                driftY: (rng.next() - 0.5) * 28,
                duration: 2.8 + rng.next() * 3.2,
                delay: rng.next() * 3.0,
                baseOpacity: 0.3 + rng.next() * 0.45
            )
        }
    }()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    FireflyDot(
                        particle: p,
                        canvasSize: geo.size,
                        highContrast: highContrast
                    )
                }
            }
        }
        .clipped()
    }
}

private struct FireflyDot: View {
    let particle: Particle
    let canvasSize: CGSize
    let highContrast: Bool

    @State private var drifted = false
    @State private var glowing = false

    var body: some View {
        let x = particle.xFraction * canvasSize.width
        let y = particle.yFraction * canvasSize.height
        let color = highContrast ? Color.white : particle.color

        Circle()
            .fill(color)
            .frame(width: particle.size, height: particle.size)
            .blur(radius: particle.size * 0.6)
            .opacity(glowing ? particle.baseOpacity : particle.baseOpacity * 0.25)
            .offset(
                x: x + (drifted ? particle.driftX : 0),
                y: y + (drifted ? particle.driftY : 0)
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: particle.duration)
                    .repeatForever(autoreverses: true)
                    .delay(particle.delay)
                ) {
                    drifted = true
                }
                withAnimation(
                    .easeInOut(duration: particle.duration * 0.7)
                    .repeatForever(autoreverses: true)
                    .delay(particle.delay * 0.5)
                ) {
                    glowing = true
                }
            }
    }
}

private struct Particle: Identifiable {
    let id: Int
    let xFraction: Double
    let yFraction: Double
    let size: Double
    let color: Color
    let driftX: Double
    let driftY: Double
    let duration: Double
    let delay: Double
    let baseOpacity: Double
}

// Simple deterministic RNG so particles are stable across redraws
private struct SeededRNG {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    mutating func next() -> Double {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        let value = Double((state >> 33) & 0x7FFFFFFF) / Double(0x7FFFFFFF)
        return value
    }
}
