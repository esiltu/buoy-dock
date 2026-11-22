import AppKit
import SwiftUI

enum Links {
    static let repository = URL(string: "https://github.com/esiltu/buoy-dock")!
    static let issues = URL(string: "https://github.com/esiltu/buoy-dock/issues")!
}

extension Bundle {
    var shortVersion: String { infoDictionary?["CFBundleShortVersionString"] as? String ?? "dev" }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let settings = DockSettings()
    private var model: DockModel!
    private var dock: DockController!
    private var statusItem: NSStatusItem!
    private var visibilityItem: NSMenuItem!
    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let arguments = CommandLine.arguments
        if let index = arguments.firstIndex(of: "--render-docs") {
            let folder = arguments.indices.contains(index + 1) ? arguments[index + 1] : "docs"
            DocsRenderer.render(to: URL(fileURLWithPath: folder)) { exit(0) }
            return
        }
        if isAnotherInstanceRunning() {
            NSApp.terminate(nil)
            return
        }

        model = DockModel()
        dock = DockController(model: model, settings: settings)
        setUpStatusItem()

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.offerToHideSystemDock()
            let defaults = UserDefaults.standard
            if !defaults.bool(forKey: "didShowWelcome") || arguments.contains("--settings") {
                defaults.set(true, forKey: "didShowWelcome")
                self.openSettings()
            }
        }
    }

    /// Double-clicking Buoy.app while it's running opens the settings.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        openSettings()
        return false
    }

    private func isAnotherInstanceRunning() -> Bool {
        guard let id = Bundle.main.bundleIdentifier else { return false }
        let me = ProcessInfo.processInfo.processIdentifier
        return NSRunningApplication.runningApplications(withBundleIdentifier: id)
            .contains { $0.processIdentifier != me }
    }

    /// Two docks on screen? Ask whether Buoy may tuck the macOS Dock away (one click, the user decides).
    private func offerToHideSystemDock() {
        guard SystemDock.showsAtBottom else { return }
        let defaults = UserDefaults.standard
        // Hidden by an earlier build but still popping up at the bottom: that's a new question.
        let upgrading = SystemDock.isHiddenByBuoy
        let suppressKey = upgrading ? "dontAskSystemDockEdge" : "dontAskSystemDock"
        guard !defaults.bool(forKey: suppressKey) else { return }

        let alert = NSAlert()
        if upgrading {
            alert.messageText = "The macOS Dock still pops up at the bottom"
            alert.informativeText = "macOS ignores the auto-hide delay, so Apple's Dock appears behind Buoy when you reach the bottom edge. Buoy can move it, small and hidden, to the left edge so only Buoy shows at the bottom. You can restore it anytime in Settings › macOS Dock."
            alert.addButton(withTitle: "Move macOS Dock")
        } else {
            alert.messageText = "Two docks on screen"
            alert.informativeText = "Apple's Dock is still showing underneath Buoy. Should Buoy tuck it away (small and hidden at the left edge)? You can restore it exactly as it was anytime in Settings › macOS Dock."
            alert.addButton(withTitle: "Hide macOS Dock")
        }
        alert.addButton(withTitle: "Not Now")
        alert.showsSuppressionButton = true
        alert.suppressionButton?.title = "Don't ask again"

        NSApp.activate()
        let response = alert.runModal()
        if alert.suppressionButton?.state == .on { defaults.set(true, forKey: suppressKey) }
        if response == .alertFirstButtonReturn { SystemDock.hide() }
    }

    // MARK: - Menu bar

    private func setUpStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "dock.rectangle", accessibilityDescription: "Buoy")

        let menu = NSMenu()
        menu.delegate = self

        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        visibilityItem = NSMenuItem(title: "Hide Dock", action: #selector(toggleDock), keyEquivalent: "")
        visibilityItem.target = self
        menu.addItem(visibilityItem)

        menu.addItem(.separator())

        let starItem = NSMenuItem(title: "Star Buoy on GitHub", action: #selector(openRepository), keyEquivalent: "")
        starItem.target = self
        menu.addItem(starItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Buoy", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.target = NSApp
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        visibilityItem.title = dock.isVisible ? "Hide Dock" : "Show Dock"
    }

    @objc private func toggleDock() {
        dock.setVisible(!dock.isVisible)
    }

    @objc private func openRepository() {
        NSWorkspace.shared.open(Links.repository)
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            let controller = NSHostingController(rootView: SettingsView(settings: settings, model: model))
            let window = NSWindow(contentViewController: controller)
            window.title = "Buoy"
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.isReleasedWhenClosed = false
            window.center()
            settingsWindow = window
        }
        NSApp.activate()
        settingsWindow?.makeKeyAndOrderFront(nil)
    }
}
