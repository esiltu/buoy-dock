import Foundation

/// Tucks the standard macOS Dock away or restores it. Only ever runs when the user clicks for it.
///
/// macOS 27 ignores `autohide-delay`, so hiding alone isn't enough: the Dock would still pop up at the
/// bottom, right where Buoy lives. Buoy therefore also moves it, small, to the left edge. The original
/// values are saved and put back exactly on restore.
enum SystemDock {
    private static let domain = "com.apple.dock" as CFString
    private static let managedKeys = ["autohide", "autohide-delay", "orientation", "tilesize", "magnification"]
    private static let backupKey = "originalDockPreferences"
    private static let legacyAutohideKey = "originalDockAutohide"
    private static let legacyDelayKey = "originalDockAutohideDelay"

    static var isHiddenByBuoy: Bool {
        backup != nil || UserDefaults.standard.object(forKey: legacyAutohideKey) != nil
    }

    /// Can the macOS Dock still appear at the bottom, where Buoy is?
    static var showsAtBottom: Bool {
        CFPreferencesAppSynchronize(domain)
        let autohide = value("autohide") as? Bool ?? false
        let orientation = value("orientation") as? String ?? "bottom"
        return !autohide || orientation == "bottom"
    }

    static func hide() {
        migrateLegacyBackup()
        if backup == nil {
            var saved: [String: Any] = [:]
            for key in managedKeys {
                if let current = value(key) { saved[key] = current }
            }
            UserDefaults.standard.set(saved, forKey: backupKey)
        }
        set("autohide", kCFBooleanTrue)
        set("autohide-delay", NSNumber(value: 1000.0))
        set("orientation", "left" as CFString)
        set("tilesize", NSNumber(value: 16.0))
        set("magnification", kCFBooleanFalse)
        CFPreferencesAppSynchronize(domain)
        restartDock()
    }

    static func restore() {
        migrateLegacyBackup()
        let saved = backup ?? [:]
        for key in managedKeys {
            set(key, saved[key] as CFPropertyList?)   // a key that didn't exist before gets removed again
        }
        CFPreferencesAppSynchronize(domain)
        UserDefaults.standard.removeObject(forKey: backupKey)
        restartDock()
    }

    // MARK: - Internals

    private static var backup: [String: Any]? {
        UserDefaults.standard.dictionary(forKey: backupKey)
    }

    private static func value(_ key: String) -> CFPropertyList? {
        CFPreferencesCopyAppValue(key as CFString, domain)
    }

    private static func set(_ key: String, _ value: CFPropertyList?) {
        CFPreferencesSetAppValue(key as CFString, value, domain)
    }

    /// An early build only saved auto-hide and its delay; complete that with the current
    /// (still untouched) position, size and magnification.
    private static func migrateLegacyBackup() {
        let defaults = UserDefaults.standard
        guard backup == nil, let autohide = defaults.object(forKey: legacyAutohideKey) as? Bool else { return }
        var saved: [String: Any] = ["autohide": autohide]
        if let delay = defaults.object(forKey: legacyDelayKey) as? Double { saved["autohide-delay"] = delay }
        for key in ["orientation", "tilesize", "magnification"] {
            if let current = value(key) { saved[key] = current }
        }
        defaults.set(saved, forKey: backupKey)
        defaults.removeObject(forKey: legacyAutohideKey)
        defaults.removeObject(forKey: legacyDelayKey)
    }

    private static func restartDock() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        process.arguments = ["Dock"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try? process.run()
        process.waitUntilExit()
    }
}
