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

struct LocalLanguageRepository: LanguageRepository, FairnessConfigRepository {
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

    func loadFairnessConfig() throws -> FairnessConfig {
        try decode("fairness_config")
    }

    private func decode<T: Decodable>(_ resourceName: String) throws -> T {
        guard let url = resourceURL(named: resourceName) else {
            throw RepositoryError.missingResource("\(resourceName).json")
        }
        let data = try Data(contentsOf: url)
        return try decoder.decode(T.self, from: data)
    }

    private func resourceURL(named name: String) -> URL? {
        let bundles = [Bundle.main, Bundle(for: BundleLocator.self)] + Bundle.allBundles + Bundle.allFrameworks
        for bundle in bundles {
            if let url = bundle.url(forResource: name, withExtension: "json") {
                return url
            }
        }
        return nil
    }
}

private final class BundleLocator {}
