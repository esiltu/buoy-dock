import Foundation
import Combine

enum HideMode: String, CaseIterable, Identifiable {
    case never, whenCovered, always

    var id: String { rawValue }

    var title: String {
        switch self {
        case .never: "Always visible"
        case .whenCovered: "Dodge windows"
        case .always: "Auto-hide"
        }
    }

    var explanation: String {
        switch self {
        case .never: "The dock always stays on screen, even above windows."
        case .whenCovered: "When the active window reaches the dock, it slides away. Push the pointer against the bottom edge to bring it back."
        case .always: "The dock stays hidden until you push the pointer against the bottom edge."
        }
    }
}

/// User settings stored in UserDefaults, plus the dock's derived measurements.
@MainActor
final class DockSettings: ObservableObject {
    private enum Key {
        static let iconSize = "iconSize"
        static let magnification = "magnification"
        static let bottomMargin = "bottomMargin"
        static let hideMode = "hideMode"
        static let legacyAutoHide = "autoHide"
        static let showRunningApps = "showRunningApps"
        static let showTrash = "showTrash"
    }

    private let defaults = UserDefaults.standard
    /// False for previews and README renders, so they never touch your real settings.
    private let persist: Bool

    @Published var iconSize: Double { didSet { save(iconSize, Key.iconSize) } }
    /// 1.0 = no magnification, 2.0 = twice as large under the pointer.
    @Published var magnification: Double { didSet { save(magnification, Key.magnification) } }
    @Published var bottomMargin: Double { didSet { save(bottomMargin, Key.bottomMargin) } }
    @Published var hideMode: HideMode { didSet { save(hideMode.rawValue, Key.hideMode) } }
    @Published var showRunningApps: Bool { didSet { save(showRunningApps, Key.showRunningApps) } }
    @Published var showTrash: Bool { didSet { save(showTrash, Key.showTrash) } }

    init(persist: Bool = true) {
        self.persist = persist
        defaults.register(defaults: [
            Key.iconSize: 52.0,
            Key.magnification: 1.5,
            Key.bottomMargin: 12.0,
            Key.showRunningApps: true,
            Key.showTrash: true,
        ])
        iconSize = defaults.double(forKey: Key.iconSize)
        magnification = defaults.double(forKey: Key.magnification)
        bottomMargin = defaults.double(forKey: Key.bottomMargin)
        if let raw = defaults.string(forKey: Key.hideMode), let mode = HideMode(rawValue: raw) {
            hideMode = mode
        } else {
            hideMode = defaults.bool(forKey: Key.legacyAutoHide) ? .always : .whenCovered
        }
        showRunningApps = defaults.bool(forKey: Key.showRunningApps)
        showTrash = defaults.bool(forKey: Key.showTrash)
    }

    private func save(_ value: Any, _ key: String) {
        if persist { defaults.set(value, forKey: key) }
    }

    // MARK: - Derived measurements

    var spacing: CGFloat { (iconSize * 0.16).rounded() }
    var horizontalPadding: CGFloat { (iconSize * 0.2).rounded() }
    var topPadding: CGFloat { (iconSize * 0.18).rounded() }
    var bottomPadding: CGFloat { max(3, topPadding - 5) }
    /// Room for the dot under an open app (4 pt dot + 3 pt gap).
    var indicatorSpace: CGFloat { 7 }
    var separatorWidth: CGFloat { 1 + spacing }
    var barHeight: CGFloat { topPadding + iconSize + indicatorSpace + bottomPadding }
    var cornerRadius: CGFloat { (barHeight * 0.38).rounded() }
    var isMagnifying: Bool { magnification > 1.01 }
}
