import AppKit
import Combine

struct DockEntry: Identifiable, Equatable {
    enum Kind { case pinned, running, trash }

    /// Path to the .app (or a fixed id for the Trash).
    let id: String
    let url: URL
    let name: String
    let kind: Kind
}

enum DockSlot: Identifiable {
    case app(DockEntry)
    case separator(String)

    var id: String {
        switch self {
        case .app(let entry): entry.id
        case .separator(let key): "separator.\(key)"
        }
    }

    var isSeparator: Bool {
        if case .separator = self { return true }
        return false
    }
}

/// Pinned apps, running apps and everything you can do with them.
@MainActor
final class DockModel: ObservableObject {
    static let finderPath = "/System/Library/CoreServices/Finder.app"
    static let trashID = "buoy.trash"
    static var trashURL: URL { URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".Trash") }

    @Published private(set) var pinned: [String] = []
    @Published private(set) var running: [NSRunningApplication] = []
    @Published private(set) var launching: Set<String> = []

    private let defaults = UserDefaults.standard
    private let pinnedKey = "pinnedApps"
    /// False for previews and README renders.
    private let persist: Bool
    /// Preview only: which apps show a "running" dot.
    private let previewRunning: Set<String>?
    private var icons: [String: NSImage] = [:]
    private var bundleIDs: [String: String] = [:]
    private var names: [String: String] = [:]
    private var cancellables = Set<AnyCancellable>()

    init() {
        persist = true
        previewRunning = nil
        if let saved = defaults.stringArray(forKey: pinnedKey) {
            pinned = saved.filter { FileManager.default.fileExists(atPath: $0) }
        } else {
            pinned = Self.systemDockApps()
        }
        normalizeAndSave()
        refreshRunning()
        observeWorkspace()
    }

    /// A model that never saves or watches anything; used to render the README images.
    init(previewApps: [String], running: Set<String>) {
        persist = false
        previewRunning = running
        pinned = previewApps.filter { FileManager.default.fileExists(atPath: $0) }
        normalizeAndSave()
    }

    // MARK: - Entries

    var pinnedEntries: [DockEntry] {
        pinned.map { entry(path: $0, kind: .pinned) }
    }

    var unpinnedRunningEntries: [DockEntry] {
        let pinnedPaths = Set(pinned)
        let pinnedBundleIDs = Set(pinned.compactMap(bundleID(for:)))
        return running.compactMap { app in
            guard let path = app.bundleURL?.path else { return nil }
            if pinnedPaths.contains(path) { return nil }
            if let id = app.bundleIdentifier, pinnedBundleIDs.contains(id) { return nil }
            return entry(path: path, kind: .running)
        }
    }

    var trashEntry: DockEntry {
        DockEntry(id: Self.trashID, url: Self.trashURL, name: "Trash", kind: .trash)
    }

    func isFinder(_ entry: DockEntry) -> Bool { entry.id == Self.finderPath }

    func canReorder(_ entry: DockEntry) -> Bool { entry.kind == .pinned && !isFinder(entry) }

    func isRunning(_ entry: DockEntry) -> Bool {
        guard entry.kind != .trash else { return false }
        if let previewRunning { return previewRunning.contains(entry.id) }
        return runningApp(forPath: entry.id) != nil
    }

    func icon(for entry: DockEntry) -> NSImage {
        if let cached = icons[entry.id] { return cached }
        let source: NSImage
        if entry.kind == .trash, let trash = NSImage(named: NSImage.trashEmptyName) {
            source = trash
        } else {
            // Resolve symlinks (e.g. /Applications/Safari.app) so the icon has no alias arrow.
            source = NSWorkspace.shared.icon(forFile: entry.url.resolvingSymlinksInPath().path)
        }
        let image = Self.rasterize(source)
        icons[entry.id] = image
        return image
    }

    /// Turns a system icon (a lazily drawn, multi-representation image) into one plain 512 px bitmap:
    /// sharp up to 2× magnification on Retina, cheap to draw, and renderable off screen.
    private static func rasterize(_ icon: NSImage, points: CGFloat = 256) -> NSImage {
        let pixels = Int(points * 2)
        guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels, bitsPerSample: 8,
                                         samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                                         bytesPerRow: 0, bitsPerPixel: 0) else { return icon }
        rep.size = NSSize(width: points, height: points)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        NSGraphicsContext.current?.imageInterpolation = .high
        icon.draw(in: NSRect(x: 0, y: 0, width: points, height: points))
        NSGraphicsContext.restoreGraphicsState()
        let image = NSImage(size: rep.size)
        image.addRepresentation(rep)
        return image
    }

    // MARK: - Actions

    func open(_ entry: DockEntry) {
        if entry.kind == .trash {
            NSWorkspace.shared.open(entry.url)
            return
        }
        let id = entry.id
        if runningApp(forPath: id) == nil { startLaunching(id) }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        // For an app that's already running this sends a "reopen", just like the real Dock
        // (which opens a window if it has none).
        NSWorkspace.shared.openApplication(at: entry.url, configuration: configuration) { [weak self] _, error in
            guard error != nil else { return }
            Task { @MainActor in self?.launching.remove(id) }
        }
    }

    func quit(_ entry: DockEntry) {
        runningApp(forPath: entry.id)?.terminate()
    }

    func reveal(_ entry: DockEntry) {
        NSWorkspace.shared.activateFileViewerSelecting([entry.url])
    }

    func pin(path: String, at index: Int? = nil) {
        guard path.hasSuffix(".app"), FileManager.default.fileExists(atPath: path) else { return }
        var list = pinned
        list.removeAll { $0 == path }
        let position = min(max(index ?? list.count, 1), list.count)
        list.insert(path, at: position)
        pinned = list
        save()
    }

    func pinApps(_ urls: [URL], at index: Int) {
        var position = index
        for url in urls where url.pathExtension == "app" {
            pin(path: url.path, at: position)
            position += 1
        }
    }

    func unpin(id: String) {
        guard id != Self.finderPath else { return }
        pinned.removeAll { $0 == id }
        save()
    }

    func movePinned(from source: Int, to destination: Int) {
        guard source >= 1, destination >= 1, pinned.indices.contains(source), pinned.indices.contains(destination) else { return }
        var list = pinned
        let item = list.remove(at: source)
        list.insert(item, at: destination)
        pinned = list
        save()
    }

    func moveToTrash(_ urls: [URL]) {
        for url in urls {
            try? FileManager.default.trashItem(at: url, resultingItemURL: nil)
        }
    }

    func importFromSystemDock() {
        pinned = Self.systemDockApps()
        normalizeAndSave()
    }

    /// Reads file URLs from a drag and drop out of Finder.
    static func fileURLs(from providers: [NSItemProvider]) async -> [URL] {
        var urls: [URL] = []
        for provider in providers where provider.canLoadObject(ofClass: URL.self) {
            let url: URL? = await withCheckedContinuation { continuation in
                _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    continuation.resume(returning: url)
                }
            }
            if let url { urls.append(url) }
        }
        return urls
    }

    // MARK: - Internals

    private func entry(path: String, kind: DockEntry.Kind) -> DockEntry {
        DockEntry(id: path, url: URL(fileURLWithPath: path), name: displayName(for: path), kind: kind)
    }

    private func runningApp(forPath path: String) -> NSRunningApplication? {
        let bundleID = bundleID(for: path)
        return running.first { app in
            app.bundleURL?.path == path || (bundleID != nil && app.bundleIdentifier == bundleID)
        }
    }

    private func bundleID(for path: String) -> String? {
        if let cached = bundleIDs[path] { return cached.isEmpty ? nil : cached }
        let id = Bundle(path: path)?.bundleIdentifier ?? ""
        bundleIDs[path] = id
        return id.isEmpty ? nil : id
    }

    private func displayName(for path: String) -> String {
        if let cached = names[path] { return cached }
        var name = FileManager.default.displayName(atPath: path)
        if name.hasSuffix(".app") { name = String(name.dropLast(4)) }
        names[path] = name
        return name
    }

    private func startLaunching(_ id: String) {
        launching.insert(id)
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(10))
            self?.launching.remove(id)
        }
    }

    private func refreshRunning() {
        let me = ProcessInfo.processInfo.processIdentifier
        let apps = NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular && $0.bundleURL != nil && $0.processIdentifier != me
        }
        if apps.map(\.processIdentifier) != running.map(\.processIdentifier) {
            running = apps
        }
        // Stop the launch "hop" once an app has finished launching.
        let stillLaunching = launching.filter { path in
            guard let app = runningApp(forPath: path) else { return true }
            return !app.isFinishedLaunching
        }
        if stillLaunching != launching { launching = stillLaunching }
    }

    private func observeWorkspace() {
        NSWorkspace.shared.publisher(for: \.runningApplications)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in MainActor.assumeIsolated { self?.refreshRunning() } }
            .store(in: &cancellables)

        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didLaunchApplicationNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in MainActor.assumeIsolated { self?.refreshRunning() } }
            .store(in: &cancellables)
    }

    /// Finder always first, no duplicates.
    private func normalizeAndSave() {
        var seen: Set<String> = [Self.finderPath]
        var list = [Self.finderPath]
        for path in pinned where !seen.contains(path) {
            seen.insert(path)
            list.append(path)
        }
        pinned = list
        save()
    }

    private func save() {
        guard persist else { return }
        defaults.set(pinned, forKey: pinnedKey)
    }

    /// The apps pinned in the standard macOS Dock.
    static func systemDockApps() -> [String] {
        guard let items = CFPreferencesCopyAppValue("persistent-apps" as CFString, "com.apple.dock" as CFString) as? [[String: Any]] else {
            return []
        }
        return items.compactMap { item in
            guard let tile = item["tile-data"] as? [String: Any],
                  let file = tile["file-data"] as? [String: Any],
                  let string = file["_CFURLString"] as? String else { return nil }
            let type = file["_CFURLStringType"] as? Int ?? 15
            let url = type == 0 ? URL(fileURLWithPath: string) : URL(string: string)
            guard let url, url.isFileURL, FileManager.default.fileExists(atPath: url.path) else { return nil }
            return url.path
        }
    }
}
