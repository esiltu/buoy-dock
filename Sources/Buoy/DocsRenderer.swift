import AppKit
import SwiftUI

/// Renders the README images from the real views: `Buoy --render-docs <folder>`.
/// Uses a preview model and preview settings, so your own dock and settings are never touched.
@MainActor
enum DocsRenderer {
    private static let previewApps = [
        "/Applications/Safari.app",
        "/System/Applications/Mail.app",
        "/System/Applications/Messages.app",
        "/System/Applications/Maps.app",
        "/System/Applications/Photos.app",
        "/System/Applications/Music.app",
        "/System/Applications/Calendar.app",
        "/System/Applications/Notes.app",
        "/System/Applications/App Store.app",
        "/System/Applications/System Settings.app",
    ]
    private static let previewRunning: Set<String> = [
        DockModel.finderPath, "/Applications/Safari.app", "/System/Applications/Mail.app", "/System/Applications/Music.app",
    ]

    static func render(to folder: URL, completion: @escaping () -> Void) {
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        let settings = DockSettings(persist: false)
        settings.iconSize = 64
        settings.magnification = 1.7
        settings.bottomMargin = 22
        settings.showRunningApps = false
        settings.showTrash = true
        settings.hideMode = .whenCovered
        let model = DockModel(previewApps: previewApps, running: previewRunning)

        writeIcon(to: folder.appendingPathComponent("icon.png"))
        renderHero(model: model, settings: settings, to: folder.appendingPathComponent("hero.png"))
        renderSettings(model: model, settings: settings, to: folder.appendingPathComponent("settings.png"), completion: completion)
    }

    // MARK: - Hero

    private static func renderHero(model: DockModel, settings: DockSettings, to url: URL) {
        let ui = DockUIState()
        var slots = model.pinnedEntries.map(DockSlot.app)
        slots += [.separator("trash"), .app(model.trashEntry)]
        let base = FisheyeLayout(slots: slots, iconSize: settings.iconSize, spacing: settings.spacing,
                                 separatorWidth: settings.separatorWidth, magnification: settings.magnification,
                                 pointerX: nil, magnify: false)
        let photosIndex = model.pinned.firstIndex(of: "/System/Applications/Photos.app") ?? 3
        ui.pointer = DockPointer(x: base.centers[photosIndex], y: 30)

        let renderer = ImageRenderer(content: DocsHeroScene(model: model, settings: settings, ui: ui))
        renderer.scale = 2
        write(renderer.cgImage, to: url)
    }

    // MARK: - Settings

    private static func renderSettings(model: DockModel, settings: DockSettings, to url: URL, completion: @escaping () -> Void) {
        // Tall enough to show every section without scrolling.
        let size = NSSize(width: 500, height: 925)
        let window = DocsWindow(contentRect: NSRect(origin: NSPoint(x: -6000, y: 200), size: size),
                                styleMask: [.borderless], backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: .aqua)
        let host = NSHostingView(rootView: SettingsView(settings: settings, model: model, height: size.height))
        window.contentView = host
        window.orderFrontRegardless()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if let screenshot = snapshot(host, background: NSColor(srgbRed: 0.95, green: 0.95, blue: 0.96, alpha: 1)) {
                let window = ImageRenderer(content: DocsWindowOnly(screenshot: screenshot))
                window.scale = 2
                write(window.cgImage, to: url.deletingLastPathComponent().appendingPathComponent("settings-window.png"))
                let scene = ImageRenderer(content: DocsSettingsScene(screenshot: screenshot))
                scene.scale = 2
                write(scene.cgImage, to: url)
            }
            window.orderOut(nil)
            completion()
        }
    }

    // MARK: - Helpers

    private static func writeIcon(to url: URL) {
        let icon = NSApp.applicationIconImage ?? NSImage()
        let pixels = 512
        guard let rep = bitmap(width: pixels, height: pixels) else { return }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        icon.draw(in: NSRect(x: 0, y: 0, width: pixels, height: pixels))
        NSGraphicsContext.restoreGraphicsState()
        try? rep.representation(using: .png, properties: [:])?.write(to: url)
    }

    private static func snapshot(_ view: NSView, background: NSColor, scale: CGFloat = 2) -> NSImage? {
        guard let layer = view.layer else { return nil }
        let size = view.bounds.size
        guard let rep = bitmap(width: Int(size.width * scale), height: Int(size.height * scale)),
              let context = NSGraphicsContext(bitmapImageRep: rep)?.cgContext else { return nil }
        context.setFillColor(background.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: rep.pixelsWide, height: rep.pixelsHigh))
        context.scaleBy(x: scale, y: scale)
        if view.isFlipped {
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1, y: -1)
        }
        layer.render(in: context)
        let image = NSImage(size: size)
        image.addRepresentation(rep)
        return image
    }

    private static func bitmap(width: Int, height: Int) -> NSBitmapImageRep? {
        NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height, bitsPerSample: 8,
                         samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                         bytesPerRow: 0, bitsPerPixel: 0)
    }

    private static func write(_ image: CGImage?, to url: URL) {
        guard let image else { return }
        let rep = NSBitmapImageRep(cgImage: image)
        try? rep.representation(using: .png, properties: [:])?.write(to: url)
    }
}

/// Lets the render window sit off screen (macOS would otherwise pull it into view).
private final class DocsWindow: NSWindow {
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect { frameRect }
}

/// A warm, original backdrop for the README images, matching the website.
private struct DocsWallpaper: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.965, green: 0.894, blue: 0.812), Color(red: 0.937, green: 0.761, blue: 0.604), Color(red: 0.851, green: 0.541, blue: 0.322)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            Ellipse()
                .fill(Color(red: 1.0, green: 0.925, blue: 0.84).opacity(0.85))
                .frame(width: 900, height: 260)
                .rotationEffect(.degrees(-10))
                .offset(x: 280, y: -90)
                .blur(radius: 70)
            Ellipse()
                .fill(Color(red: 0.66, green: 0.38, blue: 0.2).opacity(0.5))
                .frame(width: 1000, height: 300)
                .rotationEffect(.degrees(8))
                .offset(x: -280, y: 170)
                .blur(radius: 80)
        }
    }
}

private struct DocsHeroScene: View {
    let model: DockModel
    let settings: DockSettings
    let ui: DockUIState

    var body: some View {
        ZStack(alignment: .bottom) {
            DocsWallpaper()
            DockView(model: model, settings: settings, ui: ui)
                .padding(.bottom, settings.bottomMargin)
        }
        .frame(width: 1280, height: 420)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .environment(\.docsRendering, true)
        .environment(\.colorScheme, .light)
    }
}

private struct DocsSettingsScene: View {
    let screenshot: NSImage

    var body: some View {
        ZStack {
            DocsWallpaper()
            DocsWindowOnly(screenshot: screenshot)
                .shadow(color: Color(red: 0.35, green: 0.16, blue: 0.05).opacity(0.35), radius: 30, y: 18)
        }
        .frame(width: screenshot.size.width + 160, height: screenshot.size.height + 30 + 120)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

/// The settings window on its own (light appearance), for the website.
private struct DocsWindowOnly: View {
    let screenshot: NSImage

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack(spacing: 8) {
                    ForEach([Color(red: 1.0, green: 0.37, blue: 0.34), Color(red: 1.0, green: 0.74, blue: 0.18), Color(red: 0.16, green: 0.79, blue: 0.25)], id: \.self) { color in
                        Circle().fill(color).frame(width: 12, height: 12)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 14)
                Text("Buoy")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.8))
            }
            .frame(width: screenshot.size.width, height: 30)
            .background(Color(white: 0.93))

            Image(nsImage: screenshot)
                .resizable()
                .frame(width: screenshot.size.width, height: screenshot.size.height)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(.black.opacity(0.1)))
        .environment(\.colorScheme, .light)
    }
}
