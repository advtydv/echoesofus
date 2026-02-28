import Foundation

enum BundleResourceFinder {
    private static let anchor: AnyClass = BundleAnchor.self

    static func url(forResource name: String, withExtension ext: String) -> URL? {
        let bundles = [Bundle.main, Bundle(for: anchor)] + Bundle.allBundles + Bundle.allFrameworks
        for bundle in bundles {
            if let url = bundle.url(forResource: name, withExtension: ext) {
                return url
            }
        }
        return nil
    }

    static func url(forRelativePath relativePath: String) -> URL? {
        let bundles = [Bundle.main, Bundle(for: anchor)] + Bundle.allBundles + Bundle.allFrameworks
        for bundle in bundles {
            if let base = bundle.resourceURL {
                let candidate = base.appendingPathComponent(relativePath)
                if FileManager.default.fileExists(atPath: candidate.path) {
                    return candidate
                }
            }
        }
        return nil
    }
}

private final class BundleAnchor {}
