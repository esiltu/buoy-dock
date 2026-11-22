import SwiftUI

extension EnvironmentValues {
    /// True while rendering README images: Liquid Glass can't be captured off screen, so a
    /// frosted stand-in is drawn instead.
    @Entry var docsRendering = false
}

struct DockItemView: View {
    let name: String
    let icon: NSImage
    let size: CGFloat
    let isRunning: Bool
    let isLaunching: Bool
    let tooltip: String?
    let isLifted: Bool
    let isDimmed: Bool
    let isDropTarget: Bool

    @State private var hop = false

    var body: some View {
        VStack(spacing: 3) {
            Image(nsImage: icon)
                .resizable()
                .interpolation(.high)
                .frame(width: size, height: size)
                .scaleEffect(isDropTarget ? 1.12 : (isLifted ? 1.06 : 1), anchor: .bottom)
                .shadow(color: .black.opacity(isLifted ? 0.35 : 0), radius: 10, y: 6)
                .opacity(isDimmed ? 0.45 : 1)
                .offset(y: hop ? -size * 0.24 : 0)

            Circle()
                .fill(.primary.opacity(0.8))
                .frame(width: 4, height: 4)
                .opacity(isRunning ? 1 : 0)
        }
        .overlay(alignment: .top) {
            if let tooltip {
                // A zero-height frame on the top edge: the label hangs from it, just above the icon.
                TooltipLabel(text: tooltip)
                    .fixedSize()
                    .frame(height: 0, alignment: .bottom)
                    .offset(y: -6)
                    .transition(.opacity.combined(with: .scale(scale: 0.94, anchor: .bottom)))
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: isLaunching, initial: true) { _, launching in
            if launching {
                withAnimation(.easeInOut(duration: 0.42).repeatForever(autoreverses: true)) { hop = true }
            } else {
                withAnimation(.spring(duration: 0.35, bounce: 0.3)) { hop = false }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(name)
        .accessibilityAddTraits(.isButton)
    }
}

struct TooltipLabel: View {
    let text: String
    @Environment(\.docsRendering) private var docsRendering

    var body: some View {
        let label = Text(text)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
        if docsRendering {
            label
                .foregroundStyle(Color(red: 0.98, green: 0.965, blue: 0.94))
                .background(Capsule().fill(Color(red: 0.114, green: 0.094, blue: 0.078)))
        } else {
            label.glassEffect(.regular, in: .capsule)
        }
    }
}

struct DockSeparator: View {
    let height: CGFloat

    var body: some View {
        Capsule()
            .fill(.primary.opacity(0.22))
            .frame(width: 1, height: height)
    }
}

/// Liquid Glass bar with a subtle rim that lights up while you drag an app over it.
struct DockBackground: View {
    let cornerRadius: CGFloat
    let highlighted: Bool
    @Environment(\.docsRendering) private var docsRendering

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        if docsRendering {
            shape
                .fill(.white.opacity(0.45))
                .overlay(shape.strokeBorder(.white.opacity(0.75), lineWidth: 1))
                .shadow(color: Color(red: 0.35, green: 0.16, blue: 0.05).opacity(0.3), radius: 22, y: 10)
        } else {
            Color.clear
                .glassEffect(.regular, in: shape)
                .overlay {
                    shape.strokeBorder(.white.opacity(highlighted ? 0.6 : 0), lineWidth: 1.5)
                }
        }
    }
}
