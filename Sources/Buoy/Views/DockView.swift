import SwiftUI

struct DockRootView: View {
    let model: DockModel
    @ObservedObject var settings: DockSettings
    @ObservedObject var ui: DockUIState

    var body: some View {
        DockView(model: model, settings: settings, ui: ui)
            .padding(.bottom, settings.bottomMargin)
            .offset(y: ui.isHidden ? settings.barHeight + settings.bottomMargin + 30 : 0)
            .opacity(ui.isHidden ? 0 : 1)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .coordinateSpace(.named(DockView.stage))
    }
}

struct DockView: View {
    static let stage = "stage"

    @ObservedObject var model: DockModel
    @ObservedObject var settings: DockSettings
    @ObservedObject var ui: DockUIState

    @Environment(\.docsRendering) private var docsRendering
    @State private var drag: DragState?
    @State private var dragTranslation: CGSize = .zero
    @State private var fileDropActive = false
    @State private var trashDropActive = false

    private struct DragState: Equatable {
        let id: String
        let startIndex: Int
        var targetIndex: Int
        var removing: Bool
    }

    var body: some View {
        let slots = makeSlots()
        let layout = FisheyeLayout(
            slots: slots,
            iconSize: settings.iconSize,
            spacing: settings.spacing,
            separatorWidth: settings.separatorWidth,
            magnification: settings.magnification,
            pointerX: drag == nil ? ui.pointer?.x : nil,
            magnify: settings.isMagnifying
        )

        HStack(alignment: .bottom, spacing: settings.spacing) {
            ForEach(Array(slots.enumerated()), id: \.element.id) { index, slot in
                slotView(slot, index: index, layout: layout)
            }
        }
        .padding(.horizontal, settings.horizontalPadding)
        .padding(.top, settings.topPadding)
        .padding(.bottom, settings.bottomPadding)
        .background(alignment: .bottom) {
            DockBackground(cornerRadius: settings.cornerRadius, highlighted: fileDropActive)
                .frame(height: settings.barHeight)
        }
        .onGeometryChange(for: CGFloat.self, of: { $0.size.width }) { ui.dockWidth = $0 }
        .modifier(AppDrop(enabled: !docsRendering, delegate: AppDropDelegate(
            onTargeted: { active in
                withAnimation(.smooth(duration: 0.2)) { fileDropActive = active }
            },
            onDrop: { providers, location in
                let index = insertionIndex(forX: location.x - ui.dockWidth / 2, layout: layout)
                Task {
                    let urls = await DockModel.fileURLs(from: providers)
                    withAnimation(.smooth(duration: 0.3)) { model.pinApps(urls, at: index) }
                }
            }
        )))
        .animation(.smooth(duration: 0.3), value: slots.map(\.id))
    }

    // MARK: - Slots

    private func makeSlots() -> [DockSlot] {
        var slots = model.pinnedEntries.map(DockSlot.app)
        if settings.showRunningApps {
            let extra = model.unpinnedRunningEntries
            if !extra.isEmpty {
                slots.append(.separator("running"))
                slots += extra.map(DockSlot.app)
            }
        }
        if settings.showTrash {
            slots.append(.separator("trash"))
            slots.append(.app(model.trashEntry))
        }
        return slots
    }

    @ViewBuilder
    private func slotView(_ slot: DockSlot, index: Int, layout: FisheyeLayout) -> some View {
        switch slot {
        case .separator:
            DockSeparator(height: settings.iconSize * 0.62)
                .padding(.horizontal, settings.spacing / 2)
                .padding(.bottom, settings.indicatorSpace + settings.iconSize * 0.19)
                .transition(.opacity)
        case .app(let entry):
            appView(entry, scale: layout.scales[index], hovered: layout.hoveredIndex == index)
        }
    }

    private func appView(_ entry: DockEntry, scale: CGFloat, hovered: Bool) -> some View {
        let isDragged = drag?.id == entry.id
        let removing = isDragged && drag?.removing == true
        let tooltip: String? = removing ? "Remove" : (hovered && drag == nil ? entry.name : nil)

        return DockItemView(
            name: entry.name,
            icon: model.icon(for: entry),
            size: settings.iconSize * scale,
            isRunning: model.isRunning(entry),
            isLaunching: model.launching.contains(entry.id),
            tooltip: tooltip,
            isLifted: isDragged,
            isDimmed: removing,
            isDropTarget: entry.kind == .trash && trashDropActive
        )
        .offset(offset(for: entry))
        .zIndex(isDragged ? 10 : 0)
        .contentShape(Rectangle())
        .onTapGesture { model.open(entry) }
        .gesture(reorderGesture(for: entry), including: model.canReorder(entry) ? .all : .subviews)
        .modifier(OptionalContextMenu(enabled: !docsRendering) { contextMenu(for: entry) })
        .modifier(TrashDrop(enabled: entry.kind == .trash && !docsRendering, isTargeted: $trashDropActive) { providers in
            Task {
                let urls = await DockModel.fileURLs(from: providers)
                model.moveToTrash(urls)
            }
            return true
        })
        .transition(.scale(scale: 0.3, anchor: .bottom).combined(with: .opacity))
    }

    // MARK: - Reordering and removing

    private var slotWidth: CGFloat { settings.iconSize + settings.spacing }

    private func offset(for entry: DockEntry) -> CGSize {
        guard let drag, entry.kind == .pinned, let index = model.pinned.firstIndex(of: entry.id) else { return .zero }
        if entry.id == drag.id { return dragTranslation }
        if drag.startIndex < drag.targetIndex, index > drag.startIndex, index <= drag.targetIndex {
            return CGSize(width: -slotWidth, height: 0)
        }
        if drag.targetIndex < drag.startIndex, index >= drag.targetIndex, index < drag.startIndex {
            return CGSize(width: slotWidth, height: 0)
        }
        return .zero
    }

    private func reorderGesture(for entry: DockEntry) -> some Gesture {
        DragGesture(minimumDistance: 6, coordinateSpace: .named(Self.stage))
            .onChanged { value in updateDrag(entry, translation: value.translation) }
            .onEnded { _ in endDrag() }
    }

    private func updateDrag(_ entry: DockEntry, translation: CGSize) {
        if drag == nil {
            guard let start = model.pinned.firstIndex(of: entry.id) else { return }
            ui.isDragging = true
            withAnimation(.smooth(duration: 0.2)) {
                drag = DragState(id: entry.id, startIndex: start, targetIndex: start, removing: false)
            }
        }
        guard let state = drag else { return }
        dragTranslation = translation

        let removing = translation.height < -settings.iconSize * 1.1
        let proposed = state.startIndex + Int((translation.width / slotWidth).rounded())
        let target = removing ? state.startIndex : min(max(proposed, 1), model.pinned.count - 1)
        if target != state.targetIndex || removing != state.removing {
            withAnimation(.smooth(duration: 0.22)) {
                drag?.targetIndex = target
                drag?.removing = removing
            }
        }
    }

    private func endDrag() {
        guard let state = drag else { return }
        ui.isDragging = false
        withAnimation(.smooth(duration: 0.32)) {
            if state.removing {
                model.unpin(id: state.id)
            } else if state.targetIndex != state.startIndex {
                model.movePinned(from: state.startIndex, to: state.targetIndex)
            }
            drag = nil
            dragTranslation = .zero
        }
    }

    /// Where an app dropped from Finder lands among the pinned apps.
    private func insertionIndex(forX x: CGFloat, layout: FisheyeLayout) -> Int {
        let pinnedCount = model.pinned.count
        let before = layout.centers.prefix(pinnedCount).filter { $0 < x }.count
        return min(max(before, 1), pinnedCount)
    }

    // MARK: - Context menu

    @ViewBuilder
    private func contextMenu(for entry: DockEntry) -> some View {
        if entry.kind == .trash {
            Button("Open Trash") { model.open(entry) }
        } else {
            let running = model.isRunning(entry)
            Button(running ? "Show" : "Open") { model.open(entry) }
            Divider()
            if entry.kind == .pinned {
                if !model.isFinder(entry) {
                    Button("Remove from Dock") {
                        withAnimation(.smooth(duration: 0.3)) { model.unpin(id: entry.id) }
                    }
                }
            } else {
                Button("Keep in Dock") {
                    withAnimation(.smooth(duration: 0.3)) { model.pin(path: entry.id) }
                }
            }
            Button("Show in Finder") { model.reveal(entry) }
            if running && !model.isFinder(entry) {
                Divider()
                Button("Quit") { model.quit(entry) }
            }
        }
    }
}

// MARK: - Drag and drop from Finder

private struct AppDropDelegate: DropDelegate {
    let onTargeted: (Bool) -> Void
    let onDrop: ([NSItemProvider], CGPoint) -> Void

    func validateDrop(info: DropInfo) -> Bool { info.hasItemsConforming(to: [.fileURL]) }
    func dropEntered(info: DropInfo) { onTargeted(true) }
    func dropExited(info: DropInfo) { onTargeted(false) }
    func dropUpdated(info: DropInfo) -> DropProposal? { DropProposal(operation: .copy) }

    func performDrop(info: DropInfo) -> Bool {
        onTargeted(false)
        onDrop(info.itemProviders(for: [.fileURL]), info.location)
        return true
    }
}

/// Drop targets and context menus are platform views that can't be drawn into README images.
private struct AppDrop: ViewModifier {
    let enabled: Bool
    let delegate: AppDropDelegate

    func body(content: Content) -> some View {
        if enabled {
            content.onDrop(of: [.fileURL], delegate: delegate)
        } else {
            content
        }
    }
}

private struct OptionalContextMenu<MenuContent: View>: ViewModifier {
    let enabled: Bool
    @ViewBuilder let menu: () -> MenuContent

    func body(content: Content) -> some View {
        if enabled {
            content.contextMenu(menuItems: menu)
        } else {
            content
        }
    }
}

private struct TrashDrop: ViewModifier {
    let enabled: Bool
    @Binding var isTargeted: Bool
    let perform: ([NSItemProvider]) -> Bool

    func body(content: Content) -> some View {
        if enabled {
            content.onDrop(of: [.fileURL], isTargeted: $isTargeted.animation(.smooth(duration: 0.2)), perform: perform)
        } else {
            content
        }
    }
}
