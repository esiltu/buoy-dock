import AppKit
import SwiftUI
import Combine

/// Pointer position relative to the screen's horizontal center (x) and bottom edge (y).
struct DockPointer: Equatable {
    var x: CGFloat
    var y: CGFloat
}

@MainActor
final class DockUIState: ObservableObject {
    @Published var pointer: DockPointer?
    @Published var isHidden = false
    /// Not @Published: changes every frame while magnifying.
    var dockWidth: CGFloat = 0
    var isDragging = false
}

/// Borderless floating panel that never steals focus from the app you're working in.
final class DockPanel: NSPanel {
    /// Belongs to one Space at a time, so it slides away with that Space instead of hovering over others
    /// during a swipe; may be brought into a full-screen app's Space; hidden in Mission Control.
    static let baseBehavior: NSWindow.CollectionBehavior = [.moveToActiveSpace, .transient, .ignoresCycle, .fullScreenAuxiliary]

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 160),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.dockWindow)))
        collectionBehavior = Self.baseBehavior
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        isMovable = false
        acceptsMouseMovedEvents = true
        animationBehavior = .none
        ignoresMouseEvents = true
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    /// macOS keeps windows inside the "visible" area (above the system Dock); Buoy has to reach the edge.
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect { frameRect }
}

final class DockHostingView<Content: View>: NSHostingView<Content> {
    var onMouseActivity: (() -> Void)?
    private var mouseTracking: NSTrackingArea?

    /// The first click works right away, even while another app is active.
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let mouseTracking { removeTrackingArea(mouseTracking) }
        let area = NSTrackingArea(
            rect: .zero,
            options: [.mouseMoved, .mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        mouseTracking = area
    }

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        onMouseActivity?()
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        onMouseActivity?()
    }
}

/// Positions the panel and follows the pointer (magnification, click-through, hiding, Spaces).
@MainActor
final class DockController {
    private let panel = DockPanel()
    private let model: DockModel
    private let settings: DockSettings
    private let ui = DockUIState()
    private var monitors: [Any] = []
    private var cancellables = Set<AnyCancellable>()
    private var hideTask: Task<Void, Never>?
    private var switchCheckTask: Task<Void, Never>?
    private var spaceCheckTask: Task<Void, Never>?
    private var coverageTimer: Timer?
    private var spaceTimer: Timer?
    private var pressStartedInDock = false
    /// The active window overlaps the dock (only used by the "Dodge windows" mode).
    private var isCovered = false
    /// Since when the dock has looked uncovered; it only comes back once that holds for a moment.
    private var uncoveredSince: Date?
    /// False while a full-screen app's Space is active: the dock stays on the desktop then.
    private var isOnDesktopSpace = true
    private var needsOrderFront = false
    private(set) var isVisible = true

    init(model: DockModel, settings: DockSettings) {
        self.model = model
        self.settings = settings

        let host = DockHostingView(rootView: DockRootView(model: model, settings: settings, ui: ui))
        host.onMouseActivity = { [weak self] in self?.handleMouse() }
        panel.contentView = host

        layoutPanel()
        installMonitors()
        observeChanges()
        updateCoverageMonitoring()

        isOnDesktopSpace = !Spaces.isFullScreenActive
        if isOnDesktopSpace {
            panel.orderFrontRegardless()
        } else {
            needsOrderFront = true
        }
        if settings.hideMode == .always || isCovered || !isOnDesktopSpace { hide(animated: false) }
        handleMouse()
        startSpaceWatchdog()
    }

    func setVisible(_ visible: Bool) {
        isVisible = visible
        if visible {
            // An explicit "Show Dock" always brings it back on the desktop you're looking at.
            needsOrderFront = true
            reconcileSpace()
            if ui.isHidden && !shouldAutoHide { show() }
            handleMouse()
        } else {
            panel.orderOut(nil)
        }
    }

    private var shouldAutoHide: Bool {
        // Full-screen apps fill the screen: there the dock always waits at the bottom edge.
        guard isOnDesktopSpace else { return true }
        switch settings.hideMode {
        case .never: return false
        case .always: return true
        case .whenCovered: return isCovered
        }
    }

    // MARK: - Layout

    private var screen: NSScreen? { NSScreen.screens.first }

    private func layoutPanel() {
        guard let screen else { return }
        let s = settings
        let magnifiedExtra = s.iconSize * (max(s.magnification, 1) - 1)
        let launchHop = s.iconSize * 0.3
        let tooltip: CGFloat = 48
        let height = s.bottomMargin + s.barHeight + magnifiedExtra + launchHop + tooltip
        let frame = NSRect(x: screen.frame.minX, y: screen.frame.minY, width: screen.frame.width, height: ceil(height))
        panel.setFrame(frame, display: true)
    }

    // MARK: - Pointer

    private func installMonitors() {
        let moves: NSEvent.EventTypeMask = [.mouseMoved, .leftMouseDragged, .rightMouseDragged]

        if let global = NSEvent.addGlobalMonitorForEvents(matching: moves, handler: { [weak self] _ in
            MainActor.assumeIsolated { self?.handleMouse() }
        }) {
            monitors.append(global)
        }

        if let local = NSEvent.addLocalMonitorForEvents(matching: moves.union([.leftMouseDown, .leftMouseUp]), handler: { [weak self] event in
            MainActor.assumeIsolated {
                guard let self else { return }
                switch event.type {
                case .leftMouseDown: self.pressStartedInDock = event.window === self.panel
                case .leftMouseUp: self.pressStartedInDock = false
                default: break
                }
                self.handleMouse()
            }
            return event
        }) {
            monitors.append(local)
        }
    }

    private func handleMouse() {
        guard isVisible, let screen else { return }
        let s = settings
        let frame = screen.frame
        let location = NSEvent.mouseLocation
        let dx = location.x - frame.midX
        let dy = location.y - frame.minY
        let halfWidth = max(ui.dockWidth, s.iconSize * 2) / 2
        let withinX = abs(dx) <= halfWidth + 2 && location.x >= frame.minX && location.x <= frame.maxX

        if ui.isHidden {
            // Bring it back: pointer against the bottom edge, generously around the dock.
            let inRevealZone = abs(dx) <= halfWidth + 80 && location.x >= frame.minX && location.x <= frame.maxX
            guard inRevealZone && abs(dy) <= 2 else { return }
            // In a full-screen app the (still hidden) panel first moves into that app's Space.
            if !panel.isOnActiveSpace { bringToActiveSpace() }
            show()
        }

        let magnifiedExtra = (ui.pointer != nil && s.isMagnifying) ? s.iconSize * (s.magnification - 1) + 12 : 0
        let top = s.bottomMargin + s.barHeight + magnifiedExtra
        let inside = withinX && dy >= -2 && dy <= top
        let holding = pressStartedInDock || ui.isDragging

        // Outside the dock, clicks go straight through to the windows underneath.
        setIgnoresMouse(!(inside || holding))

        let pointer = inside ? DockPointer(x: dx, y: dy) : nil
        if ui.pointer != pointer {
            if pointer == nil {
                withAnimation(.smooth(duration: 0.32)) { ui.pointer = nil }
            } else {
                withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.86)) { ui.pointer = pointer }
            }
        }

        if inside || holding {
            cancelHide()
        } else if shouldAutoHide {
            scheduleHide()
        }
    }

    private func setIgnoresMouse(_ ignore: Bool) {
        if panel.ignoresMouseEvents != ignore { panel.ignoresMouseEvents = ignore }
    }

    // MARK: - Showing and hiding

    private func scheduleHide() {
        guard hideTask == nil, !ui.isHidden else { return }
        hideTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(450))
            guard !Task.isCancelled, let self else { return }
            self.hideTask = nil
            self.hide(animated: true)
        }
    }

    private func cancelHide() {
        hideTask?.cancel()
        hideTask = nil
    }

    private func hide(animated: Bool, duration: Double = 0.4) {
        cancelHide()
        setIgnoresMouse(true)
        if animated {
            withAnimation(.smooth(duration: duration)) {
                ui.isHidden = true
                ui.pointer = nil
            }
        } else {
            ui.isHidden = true
            ui.pointer = nil
        }
    }

    private func show() {
        cancelHide()
        setIgnoresMouse(false)
        withAnimation(.smooth(duration: 0.35)) { ui.isHidden = false }
    }

    /// Hides or shows the dock based on the mode, as long as the pointer isn't on it.
    private func applyHideState() {
        if shouldAutoHide {
            if !ui.isHidden && ui.pointer == nil && !pressStartedInDock && !ui.isDragging { scheduleHide() }
        } else {
            cancelHide()
            if ui.isHidden { show() }
        }
    }

    // MARK: - Changes

    private func observeChanges() {
        settings.objectWillChange
            .debounce(for: .milliseconds(30), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in MainActor.assumeIsolated { self?.settingsChanged() } }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: NSApplication.didChangeScreenParametersNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in MainActor.assumeIsolated { self?.layoutPanel() } }
            .store(in: &cancellables)

        let workspace = NSWorkspace.shared.notificationCenter
        workspace.publisher(for: NSWorkspace.didActivateApplicationNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in MainActor.assumeIsolated { self?.contextSwitched() } }
            .store(in: &cancellables)
        workspace.publisher(for: NSWorkspace.activeSpaceDidChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in MainActor.assumeIsolated { self?.activeSpaceChanged() } }
            .store(in: &cancellables)
    }

    private func settingsChanged() {
        layoutPanel()
        updateCoverageMonitoring()
        applyHideState()
    }

    // MARK: - Spaces

    /// The Space notification can arrive while macOS still reports the previous Space, so check again
    /// a few times right after it.
    private func activeSpaceChanged() {
        reconcileSpace()
        spaceCheckTask?.cancel()
        spaceCheckTask = Task { @MainActor [weak self] in
            for delay in [0.15, 0.25, 0.4] {
                try? await Task.sleep(for: .seconds(delay))
                guard !Task.isCancelled else { return }
                self?.reconcileSpace()
            }
        }
    }

    /// Safety net: twice a second, make sure the dock is on screen whenever a desktop is active.
    private func startSpaceWatchdog() {
        let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.reconcileSpace() }
        }
        timer.tolerance = 0.2
        RunLoop.main.add(timer, forMode: .common)
        spaceTimer = timer
    }

    private func reconcileSpace() {
        let onDesktop = !Spaces.isFullScreenActive
        if onDesktop != isOnDesktopSpace {
            isOnDesktopSpace = onDesktop
            if onDesktop {
                contextSwitched()
            } else if isVisible {
                // Entering a full-screen app: hidden until you push the pointer against the bottom edge.
                hide(animated: false)
            }
        }
        guard isVisible, isOnDesktopSpace else { return }
        if needsOrderFront || !panel.isVisible || !panel.isOnActiveSpace {
            needsOrderFront = false
            bringToActiveSpace()
            handleMouse()
        }
    }

    /// Follows you to another desktop (never into a full-screen app).
    private func bringToActiveSpace() {
        panel.orderFrontRegardless()
        guard !panel.isOnActiveSpace else { return }
        // Fallback: join all Spaces for a moment so the panel lands on this one, then go back.
        panel.collectionBehavior = [.canJoinAllSpaces, .transient, .ignoresCycle, .fullScreenAuxiliary]
        panel.orderFrontRegardless()
        DispatchQueue.main.async { [panel] in panel.collectionBehavior = DockPanel.baseBehavior }
    }

    // MARK: - Dodging windows

    /// A new app's windows show up in the window list a few hundred ms late, so look a few times.
    private func contextSwitched() {
        coverageTick()
        switchCheckTask?.cancel()
        switchCheckTask = Task { @MainActor [weak self] in
            for delay in [0.1, 0.25, 0.5, 0.8] {
                try? await Task.sleep(for: .seconds(delay))
                guard !Task.isCancelled else { return }
                self?.coverageTick()
            }
        }
    }

    private func updateCoverageMonitoring() {
        guard settings.hideMode == .whenCovered else {
            coverageTimer?.invalidate()
            coverageTimer = nil
            isCovered = false
            return
        }
        isCovered = computeCoverage()
        guard coverageTimer == nil else { return }

        // Moving or resizing a window posts no notification without Accessibility access, so poll lightly.
        let timer = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.coverageTick() }
        }
        timer.tolerance = 0.1
        RunLoop.main.add(timer, forMode: .common)
        coverageTimer = timer
    }

    /// Hide right away, show only once the dock stays uncovered for half a second. Switching apps or
    /// Spaces makes windows briefly "disappear", and this keeps that from causing a flash.
    private func coverageTick() {
        guard settings.hideMode == .whenCovered, isVisible, isOnDesktopSpace else { return }

        if computeCoverage() {
            uncoveredSince = nil
            let becameCovered = !isCovered
            isCovered = true
            if becameCovered, !ui.isHidden, ui.pointer == nil, !pressStartedInDock, !ui.isDragging {
                hide(animated: true, duration: 0.2)
                return
            }
        } else if isCovered {
            let since = uncoveredSince ?? Date()
            uncoveredSince = since
            if Date().timeIntervalSince(since) >= 0.5 {
                isCovered = false
                uncoveredSince = nil
            }
        }
        applyHideState()
    }

    /// Does a window of the frontmost app overlap the dock's spot?
    private func computeCoverage() -> Bool {
        guard let screen, let front = NSWorkspace.shared.frontmostApplication,
              let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]]
        else { return false }

        let s = settings
        let width = max(ui.dockWidth, s.iconSize * 2)
        let dockRect = CGRect(x: screen.frame.midX - width / 2, y: screen.frame.minY,
                              width: width, height: s.bottomMargin + s.barHeight)
        let primaryHeight = screen.frame.maxY

        for window in windows {
            guard (window[kCGWindowOwnerPID as String] as? pid_t) == front.processIdentifier,
                  (window[kCGWindowLayer as String] as? Int) == 0,
                  let boundsInfo = window[kCGWindowBounds as String] as? NSDictionary,
                  let bounds = CGRect(dictionaryRepresentation: boundsInfo as CFDictionary)
            else { continue }
            if let alpha = window[kCGWindowAlpha as String] as? Double, alpha < 0.05 { continue }
            // The window list measures from the top; AppKit from the bottom.
            let flipped = CGRect(x: bounds.minX, y: primaryHeight - bounds.maxY, width: bounds.width, height: bounds.height)
            if flipped.intersects(dockRect) { return true }
        }
        return false
    }
}
