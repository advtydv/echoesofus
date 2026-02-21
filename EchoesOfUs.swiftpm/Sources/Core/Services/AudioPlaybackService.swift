import Foundation

@MainActor
protocol AudioPlaybackServicing: AnyObject {
    var isPlaying: Bool { get }
    func play(_ cue: AudioCue, phrase: Phrase?, missionText: String?)
    func stop()
}

enum AudioPlaybackSource {
    case nativeClip
    case helperFallback
}

struct AudioPlaybackEvent {
    let cue: AudioCue
    let source: AudioPlaybackSource
}

struct AudioCoverageSummary {
    let localClipCount: Int
    let totalManifestEntries: Int

    var statusText: String {
        guard totalManifestEntries > 0 else { return "No audio manifest loaded." }
        return "\(localClipCount)/\(totalManifestEntries) local clips available"
    }
}

@MainActor
protocol AudioManifestInspecting {
    var coverageSummary: AudioCoverageSummary { get }
    var manifest: AudioManifest { get }
}
