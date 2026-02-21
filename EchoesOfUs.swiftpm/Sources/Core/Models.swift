import Foundation

enum AppRoute {
    case dashboard
    case guided
    case studio
}

enum GuidedMode {
    case judged
    case quickAccess
}

enum LearnMode: String, CaseIterable, Identifiable {
    case guidedDeck
    case library

    var id: String { rawValue }

    var title: String {
        switch self {
        case .guidedDeck:
            return "Guided Deck"
        case .library:
            return "Phrase Library"
        }
    }
}

enum PhraseCategory: String, Codable, CaseIterable, Identifiable {
    case greetings
    case collaboration
    case help
    case gratitudeFarewell

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .greetings:
            return "Greetings"
        case .collaboration:
            return "Classroom Collaboration"
        case .help:
            return "Help and Clarification"
        case .gratitudeFarewell:
            return "Gratitude and Farewells"
        }
    }
}

enum PhraseFormality: String, Codable, CaseIterable {
    case everyday
    case respectful
    case ceremonial

    var displayName: String {
        switch self {
        case .everyday:
            return "Everyday"
        case .respectful:
            return "Respectful"
        case .ceremonial:
            return "Ceremonial"
        }
    }
}

struct LanguagePack: Codable, Identifiable {
    let id: String
    let name: String
    let region: String
    let phrases: [Phrase]
}

struct Phrase: Codable, Identifiable {
    let id: String
    let nativeText: String
    let phonetic: String
    let englishMeaning: String
    let contextNote: String
    let difficulty: Int
    let category: PhraseCategory
    let formality: PhraseFormality
    let syllables: [String]
    let relatedPhraseIDs: [String]
}

struct Mission: Codable, Identifiable {
    let id: String
    let languageID: String
    let prompt: String
    let options: [String]
    let correctAnswer: String
    let hint: String
}

enum AudioClipKind: String, Codable {
    case native
    case helper
}

struct AudioClipRef: Codable, Identifiable {
    let key: String
    let fileName: String
    let kind: AudioClipKind
    let durationSeconds: Double

    var id: String { key }
}

struct AudioManifest: Codable {
    let phraseClips: [AudioClipRef]
    let missionClips: [AudioClipRef]

    static let empty = AudioManifest(phraseClips: [], missionClips: [])

    var allClips: [AudioClipRef] {
        phraseClips + missionClips
    }
}

enum AudioCue: Hashable {
    case phrase(id: String)
    case missionPrompt(id: String)
    case missionOption(missionID: String, optionIndex: Int)

    var key: String {
        switch self {
        case let .phrase(id):
            return "phrase:\(id)"
        case let .missionPrompt(id):
            return "mission:\(id):prompt"
        case let .missionOption(missionID, optionIndex):
            return "mission:\(missionID):option:\(optionIndex)"
        }
    }
}

struct LearnerProfile {
    var highContrast: Bool = false
    var focusMode: Bool = false
    var readingSupport: Bool = false
    var bilingualHints: Bool = true
}

protocol LanguageRepository {
    func loadLanguagePacks() throws -> [LanguagePack]
    func loadMissions() throws -> [Mission]
}

protocol AdaptationEngine {
    func hintLevel(for mistakes: Int, elapsedSeconds: Int) -> Int
    func recommendedNextDifficulty(current: Int, streak: Int) -> Int
}

protocol FairnessConfigRepository {
    func loadFairnessConfig() throws -> FairnessConfig
}

struct FairnessConfig: Codable {
    let lowResourceBase: Double
    let lowResourceSlope: Double
    let lowResourceCap: Double
    let highResourceBase: Double
    let highResourceSlope: Double
    let highResourceCap: Double

    static let `default` = FairnessConfig(
        lowResourceBase: 54,
        lowResourceSlope: 0.28,
        lowResourceCap: 82,
        highResourceBase: 92,
        highResourceSlope: 0.05,
        highResourceCap: 96
    )
}

enum GuidedStep: Int, CaseIterable, Identifiable {
    case intro
    case setup
    case learn
    case mastery
    case mission
    case fairness
    case summary

    var title: String {
        switch self {
        case .intro:
            return "Why This Matters"
        case .setup:
            return "Inclusion Setup"
        case .learn:
            return "Learn"
        case .mastery:
            return "Mastery Sprint"
        case .mission:
            return "Mission"
        case .fairness:
            return "AI Fairness Lab"
        case .summary:
            return "Impact"
        }
    }

    var id: Int { rawValue }
}

enum MissionResult: Equatable {
    case correct
    case incorrect
}

enum MasteryPromptType {
    case meaningToNative
    case nativeToMeaning
}

struct MasteryPrompt: Identifiable {
    let id: String
    let phraseID: String
    let languageID: String
    let prompt: String
    let options: [String]
    let correctAnswer: String
    let type: MasteryPromptType
    let syllables: [String]
}

struct MasteryRecord {
    let phraseID: String
    var confidence: Double
    var attempts: Int
    var correctFirstTryCount: Int
    var lastPracticed: Date
}

enum SprintAnswerResult: Equatable {
    case correctFirstTry
    case correctAfterSupport
    case incorrect

    var isCorrect: Bool {
        switch self {
        case .correctFirstTry, .correctAfterSupport:
            return true
        case .incorrect:
            return false
        }
    }
}
