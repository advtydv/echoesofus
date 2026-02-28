import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var route: AppRoute = .dashboard
    @Published var guidedMode: GuidedMode = .judged

    @Published var step: GuidedStep = .intro
    @Published private(set) var completedSteps: Set<GuidedStep> = []
    @Published private(set) var visitedSteps: Set<GuidedStep> = [.intro]

    @Published var learnerProfile = LearnerProfile()
    @Published var learnMode: LearnMode = .guidedDeck

    @Published private(set) var languagePacks: [LanguagePack] = []
    @Published private(set) var missions: [Mission] = []
    @Published private(set) var fairnessConfig: FairnessConfig = .default

    @Published var activeLanguageID: String = ""
    @Published var phraseIndex: Int = 0
    @Published var revealContextNote: Bool = false

    @Published var missionIndex: Int = 0
    @Published var selectedMissionOption: String?
    @Published var missionResult: MissionResult?

    @Published var contributionAmount: Double = 40
    @Published private(set) var loadIssueMessage: String?
    @Published private(set) var isUsingFallbackData: Bool = false

    @Published private(set) var mistakes: Int = 0
    @Published private(set) var hintsUsed: Int = 0
    @Published private(set) var completedMissions: Int = 0
    @Published private(set) var perfectMissions: Int = 0

    @Published private(set) var masteryByPhraseID: [String: MasteryRecord] = [:]
    @Published private(set) var currentSprintPrompts: [MasteryPrompt] = []
    @Published var sprintIndex: Int = 0
    @Published private(set) var sprintResponsesByPromptID: [String: String] = [:]
    @Published private(set) var sprintSupportByPromptID: [String: Bool] = [:]
    @Published private(set) var isSprintSubmitted: Bool = false
    @Published private(set) var sprintFeedback: String?
    @Published private(set) var sprintScore: Int = 0
    @Published private(set) var lastSprintScore: Int = 0
    @Published private(set) var masteryDelta: Double = 0

    @Published private(set) var audioFallbackCount: Int = 0
    @Published private(set) var audioClipPlayCount: Int = 0
    @Published private(set) var lastAudioPlaybackLabel: String = "No audio played yet"

    @Published private(set) var conversations: [Conversation] = []
    @Published var activeConversationIndex: Int = 0
    @Published var conversationTurnIndex: Int = 0
    @Published var conversationSelectedOptionID: String?
    @Published private(set) var conversationTurnResults: [String: Bool] = [:]
    @Published private(set) var isConversationComplete: Bool = false
    @Published private(set) var conversationCorrectCount: Int = 0
    @Published private(set) var conversationReaction: String?

    private let repository: any (LanguageRepository & FairnessConfigRepository & ConversationRepository)
    private let adaptationEngine: any AdaptationEngine
    private let audioService: any AudioPlaybackServicing

    private let sessionStart = Date()
    private var enteredStepAt: [GuidedStep: Date] = [:]
    private var masteryBaselineConfidence: Double = 0.35

    init(
        repository: any (LanguageRepository & FairnessConfigRepository & ConversationRepository) = LocalLanguageRepository(),
        adaptationEngine: any AdaptationEngine = SessionAdaptationEngine(),
        audioService: any AudioPlaybackServicing = LocalAudioPlaybackService()
    ) {
        self.repository = repository
        self.adaptationEngine = adaptationEngine
        self.audioService = audioService

        loadContent()
        enteredStepAt[.intro] = Date()

        if let localAudioService = audioService as? LocalAudioPlaybackService {
            localAudioService.onPlaybackEvent = { [weak self] event in
                Task { @MainActor in
                    self?.handleAudioEvent(event)
                }
            }
        }
    }

    var allPhrases: [Phrase] {
        languagePacks.flatMap(\.phrases)
    }

    var currentLanguage: LanguagePack? {
        languagePacks.first(where: { $0.id == activeLanguageID })
    }

    var currentPhrase: Phrase? {
        guard let currentLanguage else { return nil }
        guard currentLanguage.phrases.indices.contains(phraseIndex) else { return nil }
        return currentLanguage.phrases[phraseIndex]
    }

    var currentMission: Mission? {
        guard missions.indices.contains(missionIndex) else { return nil }
        return missions[missionIndex]
    }

    var currentSprintPrompt: MasteryPrompt? {
        guard currentSprintPrompts.indices.contains(sprintIndex) else { return nil }
        return currentSprintPrompts[sprintIndex]
    }

    var currentSprintSelectedOption: String? {
        guard let prompt = currentSprintPrompt else { return nil }
        return sprintResponsesByPromptID[prompt.id]
    }

    var currentSprintSupportUsed: Bool {
        guard let prompt = currentSprintPrompt else { return false }
        return sprintSupportByPromptID[prompt.id] ?? false
    }

    var phraseProgressLabel: String {
        guard let currentLanguage else { return "0 / 0" }
        return "\(phraseIndex + 1) / \(currentLanguage.phrases.count)"
    }

    var sprintProgressLabel: String {
        guard !currentSprintPrompts.isEmpty else { return "0 / 0" }
        return "\(min(sprintIndex + 1, currentSprintPrompts.count)) / \(currentSprintPrompts.count)"
    }

    var sprintAnsweredCount: Int {
        currentSprintPrompts.reduce(into: 0) { partialResult, prompt in
            if sprintResponsesByPromptID[prompt.id] != nil {
                partialResult += 1
            }
        }
    }

    var sessionDuration: Int {
        Int(Date().timeIntervalSince(sessionStart))
    }

    var elapsedInCurrentStep: Int {
        Int(Date().timeIntervalSince(enteredStepAt[step] ?? sessionStart))
    }

    var lowResourceScore: Double {
        min(
            fairnessConfig.lowResourceCap,
            fairnessConfig.lowResourceBase + (contributionAmount * fairnessConfig.lowResourceSlope)
        )
    }

    var highResourceScore: Double {
        min(
            fairnessConfig.highResourceCap,
            fairnessConfig.highResourceBase + (contributionAmount * fairnessConfig.highResourceSlope)
        )
    }

    var recommendedDifficulty: Int {
        let base = currentPhrase?.difficulty ?? 2
        return adaptationEngine.recommendedNextDifficulty(current: base, streak: perfectMissions)
    }

    var masteryAverageConfidence: Double {
        let records = allPhrases.compactMap { masteryByPhraseID[$0.id]?.confidence }
        guard !records.isEmpty else { return 0.35 }
        return records.reduce(0, +) / Double(records.count)
    }

    var audioCoverageText: String {
        if let inspector = audioService as? AudioManifestInspecting {
            return inspector.coverageSummary.statusText
        }
        return "Audio coverage unavailable"
    }

    var hasCompleteAudioCoverage: Bool {
        guard let inspector = audioService as? AudioManifestInspecting else { return false }
        return inspector.coverageSummary.totalManifestEntries > 0 &&
        inspector.coverageSummary.localClipCount == inspector.coverageSummary.totalManifestEntries
    }

    func isStepUnlocked(_ target: GuidedStep) -> Bool {
        if guidedMode == .quickAccess {
            return true
        }
        return target == step || completedSteps.contains(target)
    }

    func phrases(for languageID: String) -> [Phrase] {
        languagePacks.first(where: { $0.id == languageID })?.phrases ?? []
    }

    func confidence(for phraseID: String) -> Double {
        masteryByPhraseID[phraseID]?.confidence ?? 0.35
    }

    func startGuidedJourney() {
        guidedMode = .judged
        route = .guided
        resetJourney(to: .intro)
    }

    func openQuickAccess(step target: GuidedStep) {
        guidedMode = .quickAccess
        route = .guided

        selectedMissionOption = nil
        missionResult = nil
        mistakes = 0

        if target == .mission {
            missionIndex = 0
        }

        if target == .learn {
            phraseIndex = 0
            revealContextNote = false
        }

        if target == .fairness {
            contributionAmount = 40
        }

        if target == .conversation {
            startConversation()
        }

        completedSteps = Set(GuidedStep.allCases.filter { $0.rawValue < target.rawValue })
        visitedSteps = completedSteps.union([target])
        moveToStep(target)

        if target == .mastery {
            startMasterySprint()
        }
    }

    func goToDashboard() {
        audioService.stop()
        route = .dashboard
    }

    func goBackStep() {
        guard let previous = GuidedStep(rawValue: step.rawValue - 1) else {
            goToDashboard()
            return
        }

        moveToStep(previous)
    }

    func canJump(to target: GuidedStep) -> Bool {
        isStepUnlocked(target)
    }

    func jump(to target: GuidedStep) {
        guard canJump(to: target) else { return }
        moveToStep(target)
    }

    func requestHint() -> String {
        guard let mission = currentMission else { return "" }
        let elapsed = elapsedInCurrentStep
        let level = adaptationEngine.hintLevel(for: mistakes, elapsedSeconds: elapsed)
        let genericHint = "Focus on intent first: greeting, gratitude, or farewell."
        let missionHint = learnerProfile.bilingualHints ? mission.hint : genericHint
        hintsUsed += 1

        switch level {
        case 0:
            return "You're doing great. Try reading the prompt once more."
        case 1:
            return missionHint
        case 2:
            return "Focus on respectful context. \(missionHint)"
        default:
            return "Break it down: identify intent, then choose the phrase that best matches meaning and situation. \(missionHint)"
        }
    }

    func advanceStep() {
        completedSteps.insert(step)

        guard let next = GuidedStep(rawValue: step.rawValue + 1) else {
            if guidedMode == .judged {
                route = .dashboard
            }
            return
        }

        moveToStep(next)
        selectedMissionOption = nil
        missionResult = nil
    }

    func previousPhrase() {
        guard phraseIndex > 0 else { return }
        phraseIndex -= 1
        revealContextNote = false
    }

    func nextPhrase() {
        guard let language = currentLanguage else { return }
        guard phraseIndex < language.phrases.count - 1 else { return }
        phraseIndex += 1
        revealContextNote = false
    }

    func selectLanguage(_ id: String) {
        activeLanguageID = id
        phraseIndex = 0
        revealContextNote = false
    }

    func submitMissionOption(_ option: String) {
        guard let mission = currentMission else { return }
        selectedMissionOption = option

        if option == mission.correctAnswer {
            missionResult = .correct
            completedMissions += 1
            if mistakes == 0 {
                perfectMissions += 1
            }
            mistakes = 0
        } else {
            missionResult = .incorrect
            mistakes += 1
        }
    }

    func goToNextMissionOrFinish() {
        selectedMissionOption = nil
        missionResult = nil
        mistakes = 0

        guard missionIndex < missions.count - 1 else {
            advanceStep()
            return
        }
        missionIndex += 1
    }

    func startMasterySprint() {
        seedMasteryRecords(resetExisting: false)
        masteryBaselineConfidence = masteryAverageConfidence

        sprintIndex = 0
        sprintResponsesByPromptID = [:]
        sprintSupportByPromptID = [:]
        isSprintSubmitted = false
        sprintFeedback = nil
        sprintScore = 0

        let roundCount = 4
        let weakTargetCount = 3

        var selectedPhraseIDs: [String] = []
        let weakPool = weakestPhrases(limit: max(roundCount * 2, 8)).map(\.id)

        for id in weakPool where selectedPhraseIDs.count < weakTargetCount {
            selectedPhraseIDs.append(id)
        }

        let mediumPool = phrases(for: activeLanguageID)
            .filter { $0.difficulty >= 2 && $0.difficulty <= 3 }
            .map(\.id)

        for id in mediumPool where selectedPhraseIDs.count < roundCount && !selectedPhraseIDs.contains(id) {
            selectedPhraseIDs.append(id)
        }

        for phrase in allPhrases where selectedPhraseIDs.count < roundCount && !selectedPhraseIDs.contains(phrase.id) {
            selectedPhraseIDs.append(phrase.id)
        }

        currentSprintPrompts = selectedPhraseIDs
            .prefix(roundCount)
            .enumerated()
            .compactMap { index, phraseID in
                buildPrompt(for: phraseID, index: index)
            }

        if currentSprintPrompts.isEmpty, let phrase = allPhrases.first {
            currentSprintPrompts = [buildFallbackPrompt(for: phrase)]
        }
    }

    func setSprintResponse(promptID: String, option: String) {
        guard !isSprintSubmitted else { return }
        sprintResponsesByPromptID[promptID] = option
    }

    func submitSprintOption(_ option: String) {
        guard let prompt = currentSprintPrompt else { return }
        setSprintResponse(promptID: prompt.id, option: option)
    }

    func markSprintSupportUsed() {
        guard let promptID = currentSprintPrompt?.id else { return }
        sprintSupportByPromptID[promptID] = true
    }

    func goToPreviousSprintPrompt() {
        guard sprintIndex > 0 else { return }
        sprintIndex -= 1
    }

    func goToNextSprintPrompt() {
        guard sprintIndex < currentSprintPrompts.count - 1 else { return }
        sprintIndex += 1
    }

    func submitSprint() {
        guard !isSprintSubmitted else { return }
        guard !currentSprintPrompts.isEmpty else { return }

        sprintScore = 0

        for prompt in currentSprintPrompts {
            let chosenOption = sprintResponsesByPromptID[prompt.id]
            let result: SprintAnswerResult

            if chosenOption == prompt.correctAnswer {
                if sprintSupportByPromptID[prompt.id] == true {
                    result = .correctAfterSupport
                } else {
                    result = .correctFirstTry
                }
                sprintScore += 1
            } else {
                result = .incorrect
            }

            applyMasteryUpdate(phraseID: prompt.phraseID, result: result)
        }

        isSprintSubmitted = true
        sprintFeedback = "You answered \(sprintScore) of \(currentSprintPrompts.count) correctly."
        lastSprintScore = sprintScore
        masteryDelta = masteryAverageConfidence - masteryBaselineConfidence
    }

    func advanceSprint() {
        if !isSprintSubmitted {
            submitSprint()
            return
        }
        advanceStep()
    }

    func weakestPhrases(limit: Int) -> [Phrase] {
        let sorted = allPhrases.sorted { lhs, rhs in
            let leftRecord = masteryByPhraseID[lhs.id] ?? defaultMasteryRecord(for: lhs.id)
            let rightRecord = masteryByPhraseID[rhs.id] ?? defaultMasteryRecord(for: rhs.id)

            if leftRecord.confidence != rightRecord.confidence {
                return leftRecord.confidence < rightRecord.confidence
            }
            return leftRecord.lastPracticed < rightRecord.lastPracticed
        }
        return Array(sorted.prefix(max(0, limit)))
    }

    func practiceQueue(for languageID: String) -> [Phrase] {
        let phraseIDs = Set(phrases(for: languageID).map(\.id))
        return weakestPhrases(limit: 8).filter { phraseIDs.contains($0.id) }
    }

    func playPhraseAudio(for phrase: Phrase) {
        audioService.play(.phrase(id: phrase.id), phrase: phrase, missionText: nil)
    }

    func playMissionPromptAudio(for mission: Mission) {
        audioService.play(.missionPrompt(id: mission.id), phrase: nil, missionText: mission.prompt)
    }

    func playMissionOptionAudio(mission: Mission, optionIndex: Int, optionText: String) {
        audioService.play(.missionOption(missionID: mission.id, optionIndex: optionIndex), phrase: nil, missionText: optionText)
    }

    func stopAudio() {
        audioService.stop()
    }

    func restartDemo() {
        startGuidedJourney()
    }

    var currentConversation: Conversation? {
        guard conversations.indices.contains(activeConversationIndex) else { return nil }
        return conversations[activeConversationIndex]
    }

    var currentConversationTurn: ConversationTurn? {
        guard let conv = currentConversation else { return nil }
        guard conv.turns.indices.contains(conversationTurnIndex) else { return nil }
        return conv.turns[conversationTurnIndex]
    }

    var conversationFluencyScore: Double {
        guard let conv = currentConversation, !conv.turns.isEmpty else { return 0 }
        return Double(conversationCorrectCount) / Double(conv.turns.count)
    }

    var conversationProgressLabel: String {
        guard let conv = currentConversation else { return "0 / 0" }
        return "\(min(conversationTurnIndex + 1, conv.turns.count)) / \(conv.turns.count)"
    }

    func startConversation() {
        let languageConversations = conversations.filter { $0.languageID == activeLanguageID }
        if let first = languageConversations.first,
           let idx = conversations.firstIndex(where: { $0.id == first.id }) {
            activeConversationIndex = idx
        } else {
            activeConversationIndex = 0
        }
        conversationTurnIndex = 0
        conversationSelectedOptionID = nil
        conversationTurnResults = [:]
        isConversationComplete = false
        conversationCorrectCount = 0
        conversationReaction = nil
    }

    func submitConversationOption(_ optionID: String) {
        guard let turn = currentConversationTurn else { return }
        guard conversationSelectedOptionID == nil else { return }

        conversationSelectedOptionID = optionID
        let isCorrect = optionID == turn.correctOptionID

        conversationTurnResults[turn.id] = isCorrect
        if isCorrect {
            conversationCorrectCount += 1
        }

        if let option = turn.options.first(where: { $0.id == optionID }) {
            conversationReaction = option.characterReaction
        }
    }

    func advanceConversationTurn() {
        guard let conv = currentConversation else { return }
        conversationSelectedOptionID = nil
        conversationReaction = nil

        if conversationTurnIndex < conv.turns.count - 1 {
            conversationTurnIndex += 1
        } else {
            isConversationComplete = true
        }
    }

    private func moveToStep(_ target: GuidedStep) {
        step = target
        visitedSteps.insert(target)
        enteredStepAt[target] = Date()

        if target == .mastery && (currentSprintPrompts.isEmpty || isSprintSubmitted) {
            startMasterySprint()
        }

        if target == .conversation {
            startConversation()
        }

        if target == .learn && guidedMode == .judged {
            learnMode = .guidedDeck
        }
    }

    private func resetJourney(to startStep: GuidedStep) {
        step = startStep
        completedSteps = []
        visitedSteps = [startStep]
        enteredStepAt = [startStep: Date()]

        missionIndex = 0
        selectedMissionOption = nil
        missionResult = nil

        contributionAmount = 40
        mistakes = 0
        hintsUsed = 0
        completedMissions = 0
        perfectMissions = 0

        revealContextNote = false
        phraseIndex = 0
        learnMode = .guidedDeck

        currentSprintPrompts = []
        sprintIndex = 0
        sprintResponsesByPromptID = [:]
        sprintSupportByPromptID = [:]
        isSprintSubmitted = false
        sprintFeedback = nil
        sprintScore = 0
        lastSprintScore = 0
        masteryDelta = 0

        audioFallbackCount = 0
        audioClipPlayCount = 0
        lastAudioPlaybackLabel = "No audio played yet"
        audioService.stop()

        activeConversationIndex = 0
        conversationTurnIndex = 0
        conversationSelectedOptionID = nil
        conversationTurnResults = [:]
        isConversationComplete = false
        conversationCorrectCount = 0
        conversationReaction = nil

        seedMasteryRecords(resetExisting: true)
    }

    private func handleAudioEvent(_ event: AudioPlaybackEvent) {
        switch event.source {
        case .nativeClip:
            audioClipPlayCount += 1
            lastAudioPlaybackLabel = "Native clip"
        case .helperFallback:
            audioFallbackCount += 1
            lastAudioPlaybackLabel = "Helper narration (auto-generated)"
        }
    }

    private func applyMasteryUpdate(phraseID: String, result: SprintAnswerResult) {
        var record = masteryByPhraseID[phraseID] ?? defaultMasteryRecord(for: phraseID)
        record.attempts += 1
        record.lastPracticed = Date()

        switch result {
        case .correctFirstTry:
            record.correctFirstTryCount += 1
            record.confidence = min(0.95, record.confidence + 0.20)
        case .correctAfterSupport:
            record.confidence = min(0.95, record.confidence + 0.10)
        case .incorrect:
            record.confidence = max(0.05, record.confidence - 0.10)
        }

        masteryByPhraseID[phraseID] = record
    }

    private func buildPrompt(for phraseID: String, index: Int) -> MasteryPrompt? {
        guard let phrase = allPhrases.first(where: { $0.id == phraseID }) else { return nil }
        guard let languageID = languageID(for: phraseID) else { return nil }

        let sameLanguage = phrases(for: languageID)
        let type: MasteryPromptType = (index % 2 == 0) ? .meaningToNative : .nativeToMeaning

        switch type {
        case .meaningToNative:
            let correct = phrase.nativeText
            let distractors = sameLanguage
                .filter { $0.id != phrase.id }
                .map(\.nativeText)
                .uniqued()

            let options = optionSet(correct: correct, distractors: distractors, seed: index)
            return MasteryPrompt(
                id: "sprint_\(phrase.id)_\(index)",
                phraseID: phrase.id,
                languageID: languageID,
                prompt: "Choose the native phrase for: \"\(phrase.englishMeaning)\"",
                options: options,
                correctAnswer: correct,
                type: type,
                syllables: phrase.syllables
            )

        case .nativeToMeaning:
            let correct = phrase.englishMeaning
            let distractors = sameLanguage
                .filter { $0.id != phrase.id }
                .map(\.englishMeaning)
                .uniqued()

            let options = optionSet(correct: correct, distractors: distractors, seed: index)
            return MasteryPrompt(
                id: "sprint_\(phrase.id)_\(index)",
                phraseID: phrase.id,
                languageID: languageID,
                prompt: "What does \"\(phrase.nativeText)\" mean?",
                options: options,
                correctAnswer: correct,
                type: type,
                syllables: phrase.syllables
            )
        }
    }

    private func buildFallbackPrompt(for phrase: Phrase) -> MasteryPrompt {
        MasteryPrompt(
            id: "sprint_fallback_\(phrase.id)",
            phraseID: phrase.id,
            languageID: activeLanguageID,
            prompt: "Choose the native phrase for: \"\(phrase.englishMeaning)\"",
            options: [phrase.nativeText, phrase.englishMeaning],
            correctAnswer: phrase.nativeText,
            type: .meaningToNative,
            syllables: phrase.syllables
        )
    }

    private func optionSet(correct: String, distractors: [String], seed: Int) -> [String] {
        var options = Array(distractors.prefix(3))
        let index = min(seed % 4, options.count)
        options.insert(correct, at: index)
        return options.uniqued().prefix(4).map { $0 }
    }

    private func languageID(for phraseID: String) -> String? {
        for language in languagePacks where language.phrases.contains(where: { $0.id == phraseID }) {
            return language.id
        }
        return nil
    }

    private func seedMasteryRecords(resetExisting: Bool) {
        if resetExisting {
            masteryByPhraseID = [:]
        }

        for phrase in allPhrases {
            if resetExisting || masteryByPhraseID[phrase.id] == nil {
                masteryByPhraseID[phrase.id] = defaultMasteryRecord(for: phrase.id)
            }
        }
    }

    private func defaultMasteryRecord(for phraseID: String) -> MasteryRecord {
        MasteryRecord(
            phraseID: phraseID,
            confidence: 0.35,
            attempts: 0,
            correctFirstTryCount: 0,
            lastPracticed: .distantPast
        )
    }

    private func loadContent() {
        do {
            languagePacks = try repository.loadLanguagePacks()
            missions = try repository.loadMissions()
            fairnessConfig = try repository.loadFairnessConfig()
            conversations = (try? repository.loadConversations()) ?? []
            activeLanguageID = languagePacks.first?.id ?? ""

            loadIssueMessage = nil
            isUsingFallbackData = false
            seedMasteryRecords(resetExisting: true)
        } catch {
            let fallback = Self.fallbackContent
            languagePacks = fallback.languagePacks
            missions = fallback.missions
            fairnessConfig = fallback.fairness
            conversations = fallback.conversations
            activeLanguageID = fallback.languagePacks.first?.id ?? ""

            loadIssueMessage = "Live content could not be loaded. Showing built-in fallback content instead."
            isUsingFallbackData = true
            seedMasteryRecords(resetExisting: true)
        }
    }

    private static let fallbackContent: (
        languagePacks: [LanguagePack],
        missions: [Mission],
        fairness: FairnessConfig,
        conversations: [Conversation]
    ) = (
        languagePacks: [
            LanguagePack(
                id: "navajo",
                name: "Dine Bizaad (Navajo)",
                region: "Southwestern United States",
                phrases: [
                    Phrase(
                        id: "nv_1",
                        nativeText: "Yá'át'ééh",
                        phonetic: "yah-ah-teh",
                        englishMeaning: "Hello / It is good",
                        contextNote: "Used as a respectful greeting in many contexts.",
                        difficulty: 1,
                        category: .greetings,
                        formality: .respectful,
                        syllables: ["Yá", "át", "ééh"],
                        relatedPhraseIDs: ["nv_2"]
                    )
                ]
            )
        ],
        missions: [
            Mission(
                id: "fallback_mission",
                languageID: "navajo",
                prompt: "A new student joins class. Choose the most respectful opener.",
                options: ["Yá'át'ééh", "Aoo'", "Hágoónee'"],
                correctAnswer: "Yá'át'ééh",
                hint: "Pick the greeting phrase used to welcome someone."
            )
        ],
        fairness: .default,
        conversations: [
            Conversation(
                id: "fallback_conv",
                languageID: "navajo",
                scenarioTitle: "Quick Greeting",
                scenarioContext: "A classmate approaches you in the hallway.",
                characterName: "Classmate",
                characterIcon: "person.crop.circle.fill",
                turns: [
                    ConversationTurn(
                        id: "fb_t1",
                        characterLine: "Someone walks up to you. How do you greet them?",
                        options: [
                            ConversationOption(id: "fb_t1_a", nativeText: "Yá'át'ééh", isCorrect: true, characterReaction: "They smile and greet you back warmly."),
                            ConversationOption(id: "fb_t1_b", nativeText: "Hágoónee'", isCorrect: false, characterReaction: "That is a farewell. They look confused but wait for you to try again.")
                        ],
                        correctOptionID: "fb_t1_a"
                    )
                ]
            )
        ]
    )
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}
