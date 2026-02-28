import AVFoundation
import Foundation

@MainActor
final class LocalAudioPlaybackService: NSObject, AudioPlaybackServicing, AudioManifestInspecting {
    private(set) var isPlaying: Bool = false
    private var audioPlayer: AVAudioPlayer?
    private let synthesizer = AVSpeechSynthesizer()
    private let manifestData: AudioManifest
    private let clipsByKey: [String: AudioClipRef]

    var onPlaybackEvent: ((AudioPlaybackEvent) -> Void)?

    override init() {
        let loadedManifest = Self.loadManifest()
        self.manifestData = loadedManifest
        self.clipsByKey = Dictionary(uniqueKeysWithValues: loadedManifest.allClips.map { ($0.key, $0) })
        super.init()
        synthesizer.delegate = self
    }

    var manifest: AudioManifest {
        manifestData
    }

    var coverageSummary: AudioCoverageSummary {
        let total = manifestData.allClips.count
        let available = manifestData.allClips.filter { clip in
            Self.resourceURL(for: clip.fileName) != nil
        }.count

        return AudioCoverageSummary(localClipCount: available, totalManifestEntries: total)
    }

    func play(_ cue: AudioCue, phrase: Phrase?, missionText: String?) {
        stop()

        let key = cue.key
        if let clip = clipsByKey[key], let fileURL = Self.resourceURL(for: clip.fileName) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                isPlaying = true
                onPlaybackEvent?(AudioPlaybackEvent(cue: cue, source: .nativeClip))
                return
            } catch {
                // Fall through to helper narration.
            }
        }

        let fallbackText = helperText(cue: cue, phrase: phrase, missionText: missionText)
        guard !fallbackText.isEmpty else {
            isPlaying = false
            onPlaybackEvent?(AudioPlaybackEvent(cue: cue, source: .helperFallback))
            return
        }

        let utterance = AVSpeechUtterance(string: fallbackText)
        utterance.rate = 0.47
        utterance.pitchMultiplier = 1.0
        utterance.volume = 0.95
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
        isPlaying = true
        onPlaybackEvent?(AudioPlaybackEvent(cue: cue, source: .helperFallback))
    }

    func stop() {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
        }
        audioPlayer = nil

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        isPlaying = false
    }

    private func helperText(cue: AudioCue, phrase: Phrase?, missionText: String?) -> String {
        switch cue {
        case .phrase:
            guard let phrase else { return missionText ?? "" }
            return "Helper narration. Phonetic: \(phrase.phonetic). Meaning: \(phrase.englishMeaning)."
        case .missionPrompt:
            if let missionText, !missionText.isEmpty {
                return "Helper narration. Scenario prompt: \(missionText)"
            }
            return "Helper narration for mission prompt."
        case .missionOption:
            if let missionText, !missionText.isEmpty {
                return "Helper narration. Option: \(missionText)"
            }
            return "Helper narration for mission option."
        }
    }

    private static func loadManifest() -> AudioManifest {
        guard let url = BundleResourceFinder.url(forResource: "audio_manifest", withExtension: "json") else {
            return .empty
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(AudioManifest.self, from: data)
        } catch {
            return .empty
        }
    }

    private static func resourceURL(for relativePath: String) -> URL? {
        BundleResourceFinder.url(forRelativePath: relativePath)
    }
}

extension LocalAudioPlaybackService: AVAudioPlayerDelegate, AVSpeechSynthesizerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
        }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            self.isPlaying = false
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isPlaying = false
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isPlaying = false
        }
    }
}
