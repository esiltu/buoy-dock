import AppKit
import ServiceManagement
import os

/// Keeps Buoy in Login Items. Buoy hides Apple's Dock, so if it didn't start at login you'd be left
/// without any dock after a restart. On by default; turning it off in Settings is remembered.
@MainActor
enum LoginItem {
    private static let optOutKey = "loginItemOptOut"
    private static let approvalAskedKey = "loginItemApprovalAsked"
    private static let log = Logger(subsystem: "io.github.esiltu.buoy", category: "login-item")

    static var status: SMAppService.Status { SMAppService.mainApp.status }
    static var isOn: Bool { status == .enabled || status == .requiresApproval }

    /// Called at every launch: registers Buoy unless the user switched "Open at login" off themselves.
    static func ensureRegistered() {
        guard !UserDefaults.standard.bool(forKey: optOutKey) else {
            log.info("Open at login is off by choice")
            return
        }
        if status != .enabled {
            do {
                try SMAppService.mainApp.register()
            } catch {
                log.error("Registering as login item failed: \(error.localizedDescription, privacy: .public)")
            }
        }
        log.info("Login item status: \(describe(status), privacy: .public)")
        if status == .requiresApproval { askForApprovalOnce() }
    }

    static func setEnabled(_ enabled: Bool) throws {
        UserDefaults.standard.set(!enabled, forKey: optOutKey)
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }

    /// macOS can require the user to allow a login item; point them straight to the right place, once.
    private static func askForApprovalOnce() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: approvalAskedKey) else { return }
        defaults.set(true, forKey: approvalAskedKey)

        let alert = NSAlert()
        alert.messageText = "Allow Buoy to open at login"
        alert.informativeText = "Buoy replaces Apple's Dock, so it should start with your Mac. Turn Buoy on in System Settings › General › Login Items."
        alert.addButton(withTitle: "Open Login Items")
        alert.addButton(withTitle: "Not Now")
        NSApp.activate()
        if alert.runModal() == .alertFirstButtonReturn {
            SMAppService.openSystemSettingsLoginItems()
        }
    }

    private static func describe(_ status: SMAppService.Status) -> String {
        switch status {
        case .enabled: "enabled"
        case .requiresApproval: "requires approval"
        case .notRegistered: "not registered"
        case .notFound: "not found"
        @unknown default: "unknown"
        }
    }
}
