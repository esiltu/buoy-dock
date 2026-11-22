import Foundation

/// Buoy started out under the working name "Zweef". On first launch, carry over its pinned apps,
/// settings and the saved backup of the macOS Dock preferences (needed to restore Apple's Dock).
enum Migration {
    private static let legacyDomain = "local.zweef.dock"
    private static let doneKey = "importedLegacySettings"

    static func importLegacySettings() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: doneKey) else { return }
        defaults.set(true, forKey: doneKey)
        guard let legacy = defaults.persistentDomain(forName: legacyDomain) else { return }
        for (key, value) in legacy where defaults.object(forKey: key) == nil {
            defaults.set(value, forKey: key)
        }
    }
}
