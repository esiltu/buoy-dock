import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @ObservedObject var settings: DockSettings
    @ObservedObject var model: DockModel
    var height: CGFloat = 760

    @State private var loginStatus = SMAppService.mainApp.status
    @State private var loginError: String?
    @State private var systemDockHidden = !SystemDock.showsAtBottom

    var body: some View {
        Form {
            Section("macOS Dock") {
                Text(systemDockHidden
                     ? "Apple's Dock is tucked away, small and hidden at the left edge, so only Buoy shows at the bottom."
                     : "Apple's Dock can still appear at the bottom, so you'll see two docks.")
                    .foregroundStyle(.secondary)
                HStack {
                    Spacer()
                    if SystemDock.isHiddenByBuoy || systemDockHidden {
                        Button("Restore macOS Dock") {
                            SystemDock.restore()
                            systemDockHidden = !SystemDock.showsAtBottom
                        }
                    }
                    if !systemDockHidden {
                        Button("Hide macOS Dock") {
                            SystemDock.hide()
                            systemDockHidden = !SystemDock.showsAtBottom
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }

            Section("Appearance") {
                SliderRow(title: "Icon size", value: $settings.iconSize, range: 36...80, step: 2) {
                    "\(Int($0)) pt"
                }
                SliderRow(title: "Magnification", value: $settings.magnification, range: 1...2, step: 0.05) {
                    $0 <= 1.01 ? "Off" : String(format: "%.1f×", $0)
                }
                SliderRow(title: "Distance from bottom", value: $settings.bottomMargin, range: 0...48, step: 1) {
                    "\(Int($0)) pt"
                }
            }

            Section("Behavior") {
                Picker("Hiding", selection: $settings.hideMode) {
                    ForEach(HideMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                Text(settings.hideMode.explanation)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Toggle("Show open apps", isOn: $settings.showRunningApps)
                Toggle("Show Trash", isOn: $settings.showTrash)
                Toggle("Open at login", isOn: loginBinding)
                if loginStatus == .requiresApproval {
                    HStack {
                        Text("Approve Buoy in System Settings › General › Login Items.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Open") { SMAppService.openSystemSettingsLoginItems() }
                    }
                } else if loginStatus != .enabled {
                    Text("Recommended: with Apple's Dock hidden, you'd have no dock after a restart until you open Buoy.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                if let loginError {
                    Text(loginError)
                        .font(.callout)
                        .foregroundStyle(.red)
                }
            }

            Section("Apps") {
                LabeledContent("Reorder", value: "Drag an icon left or right")
                LabeledContent("Remove", value: "Drag an icon up, out of the dock")
                LabeledContent("Add", value: "Drop an app from Finder onto the dock")
                HStack {
                    Spacer()
                    Button("Import from macOS Dock") {
                        withAnimation(.smooth(duration: 0.3)) { model.importFromSystemDock() }
                    }
                }
            }

            Section("About") {
                LabeledContent("Version", value: Bundle.main.shortVersion)
                HStack {
                    Text("Free and open source. Like it? A star helps others find it.")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Link("Star on GitHub", destination: Links.repository)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 500, height: height)
    }

    private var loginBinding: Binding<Bool> {
        Binding(
            get: { loginStatus == .enabled || loginStatus == .requiresApproval },
            set: { enable in
                do {
                    try LoginItem.setEnabled(enable)
                    loginError = nil
                } catch {
                    loginError = "That didn't work: \(error.localizedDescription)"
                }
                loginStatus = SMAppService.mainApp.status
            }
        )
    }
}

private struct SliderRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let format: (Double) -> String

    var body: some View {
        LabeledContent(title) {
            HStack(spacing: 10) {
                Slider(value: $value, in: range, step: step)
                    .labelsHidden()
                    .frame(width: 190)
                Text(format(value))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .frame(width: 46, alignment: .trailing)
            }
        }
    }
}
