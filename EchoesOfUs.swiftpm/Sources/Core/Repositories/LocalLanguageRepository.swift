import Foundation

enum RepositoryError: Error {
    case missingResource(String)
    case emptyDataset(String)
    case invalidDataset(String)
}

extension RepositoryError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .missingResource(resource):
            return "Missing resource: \(resource)."
        case let .emptyDataset(resource):
            return "\(resource) is empty and cannot be used."
        case let .invalidDataset(reason):
            return "Invalid data: \(reason)."
        }
    }
}

struct LocalLanguageRepository: LanguageRepository, ConversationRepository {
    private let decoder = JSONDecoder()

    func loadLanguagePacks() throws -> [LanguagePack] {
        let packs: [LanguagePack] = try decode("language_packs")
        guard !packs.isEmpty else {
            throw RepositoryError.emptyDataset("language_packs.json")
        }
        guard packs.allSatisfy({ !$0.name.isEmpty && !$0.phrases.isEmpty }) else {
            throw RepositoryError.invalidDataset("Every language must include a name and at least one phrase.")
        }
        guard packs.allSatisfy({ pack in
            pack.phrases.allSatisfy { phrase in
                !phrase.nativeText.isEmpty &&
                !phrase.englishMeaning.isEmpty &&
                !phrase.syllables.isEmpty
            }
        }) else {
            throw RepositoryError.invalidDataset("Each phrase must include native text, meaning, and syllable data.")
        }
        return packs
    }

    func loadMissions() throws -> [Mission] {
        let missions: [Mission] = try decode("missions")
        guard !missions.isEmpty else {
            throw RepositoryError.emptyDataset("missions.json")
        }
        guard missions.allSatisfy({ mission in
            !mission.prompt.isEmpty &&
            mission.options.count >= 2 &&
            !mission.correctAnswer.isEmpty &&
            mission.options.contains(mission.correctAnswer)
        }) else {
            throw RepositoryError.invalidDataset("Every mission must include a prompt, valid options, and a matching correct answer.")
        }
        return missions
    }

    func loadConversations() throws -> [Conversation] {
        let conversations: [Conversation] = try decode("conversations")
        guard !conversations.isEmpty else {
            throw RepositoryError.emptyDataset("conversations.json")
        }
        guard conversations.allSatisfy({ conv in
            !conv.turns.isEmpty &&
            conv.turns.allSatisfy { turn in
                !turn.characterLine.isEmpty &&
                turn.options.count >= 2 &&
                turn.options.contains(where: { $0.id == turn.correctOptionID })
            }
        }) else {
            throw RepositoryError.invalidDataset("Every conversation must include turns with valid options and a matching correct option.")
        }
        return conversations
    }

    private func decode<T: Decodable>(_ resourceName: String) throws -> T {
        guard let url = BundleResourceFinder.url(forResource: resourceName, withExtension: "json") else {
            throw RepositoryError.missingResource("\(resourceName).json")
        }
        let data = try Data(contentsOf: url)
        return try decoder.decode(T.self, from: data)
    }
}
