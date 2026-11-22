// Draws the app icon (deep blue tile with a floating glass bar) and turns it into AppIcon.icns.
// Usage: swift scripts/make-icon.swift <output-folder>
import AppKit

let outputDir = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : ".")
let iconset = outputDir.appendingPathComponent("AppIcon.iconset")
try? FileManager.default.removeItem(at: iconset)
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: alpha)
}

func render(pixels: Int) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels, bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                               bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let scale = CGFloat(pixels) / 1024
    NSGraphicsContext.current!.cgContext.scaleBy(x: scale, y: scale)

    // Background
    let background = NSBezierPath(roundedRect: NSRect(x: 100, y: 100, width: 824, height: 824), xRadius: 186, yRadius: 186)
    NSGradient(colors: [color(0x0A1A4F), color(0x1F4FD8), color(0x4C86FF)])!.draw(in: background, angle: 65)

    // Soft light from the top
    NSGraphicsContext.saveGraphicsState()
    background.addClip()
    NSGradient(colors: [color(0xFFFFFF, 0.18), color(0xFFFFFF, 0)])!
        .draw(in: NSRect(x: 100, y: 560, width: 824, height: 364), angle: -90)
    NSGraphicsContext.restoreGraphicsState()

    // Floating bar with shadow
    let bar = NSBezierPath(roundedRect: NSRect(x: 252, y: 330, width: 520, height: 136), xRadius: 68, yRadius: 68)
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = color(0x000000, 0.35)
    shadow.shadowBlurRadius = 44
    shadow.shadowOffset = NSSize(width: 0, height: -26)
    shadow.set()
    color(0xFFFFFF, 0.9).setFill()
    bar.fill()
    NSGraphicsContext.restoreGraphicsState()

    // Three tiles on the bar + a dot under the middle one
    let tiles: [UInt32] = [0x1F4FD8, 0x0A1A4F, 0x6FA0FF]
    for (index, hex) in tiles.enumerated() {
        let x = 340 + CGFloat(index) * 126
        color(hex).setFill()
        NSBezierPath(roundedRect: NSRect(x: x, y: 368, width: 92, height: 76), xRadius: 22, yRadius: 22).fill()
    }
    color(0x0A1A4F, 0.7).setFill()
    NSBezierPath(ovalIn: NSRect(x: 506, y: 344, width: 12, height: 12)).fill()

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

let sizes: [(String, Int)] = [
    ("icon_16x16", 16), ("icon_16x16@2x", 32), ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256), ("icon_256x256", 256), ("icon_256x256@2x", 512),
    ("icon_512x512", 512), ("icon_512x512@2x", 1024),
]
for (name, pixels) in sizes {
    try render(pixels: pixels).write(to: iconset.appendingPathComponent("\(name).png"))
}

let iconutil = Process()
iconutil.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
iconutil.arguments = ["-c", "icns", iconset.path, "-o", outputDir.appendingPathComponent("AppIcon.icns").path]
try iconutil.run()
iconutil.waitUntilExit()
try? FileManager.default.removeItem(at: iconset)
print(iconutil.terminationStatus == 0 ? "Created AppIcon.icns" : "iconutil failed")
