import CoreGraphics

/// Computes each slot's magnification (a smooth cosine falloff around the pointer)
/// and which icon is under the pointer.
struct FisheyeLayout {
    let scales: [CGFloat]
    /// Centers after magnification, relative to the dock's center.
    let centers: [CGFloat]
    let hoveredIndex: Int?

    init(slots: [DockSlot], iconSize: CGFloat, spacing: CGFloat, separatorWidth: CGFloat,
         magnification: CGFloat, pointerX: CGFloat?, magnify: Bool) {
        let baseWidths = slots.map { $0.isSeparator ? separatorWidth : iconSize }
        let baseCenters = Self.centers(for: baseWidths, spacing: spacing)

        let range = iconSize * 2.4
        let extra = magnification - 1
        let scales: [CGFloat] = zip(slots, baseCenters).map { slot, center in
            guard magnify, let pointerX, !slot.isSeparator else { return 1 }
            let distance = abs(pointerX - center)
            guard distance < range else { return 1 }
            return 1 + extra * (cos(.pi * distance / range) + 1) / 2
        }

        let widths = zip(baseWidths, scales).map { $0 * $1 }
        let centers = Self.centers(for: widths, spacing: spacing)

        var hovered: Int?
        if let pointerX {
            for (index, slot) in slots.enumerated() where !slot.isSeparator {
                if abs(pointerX - centers[index]) <= (widths[index] + spacing) / 2 {
                    hovered = index
                    break
                }
            }
        }

        self.scales = scales
        self.centers = centers
        self.hoveredIndex = hovered
    }

    private static func centers(for widths: [CGFloat], spacing: CGFloat) -> [CGFloat] {
        let total = widths.reduce(0, +) + spacing * CGFloat(max(widths.count - 1, 0))
        var x = -total / 2
        return widths.map { width in
            defer { x += width + spacing }
            return x + width / 2
        }
    }
}
