import AppKit
import SwiftUI

struct MenuBarContent: View {
    @ObservedObject var state: AppState
    @ObservedObject private var settings: SettingsManager

    init(state: AppState) {
        self.state = state
        settings = state.settings
    }

    var body: some View {
        Toggle("Auto Switch", isOn: $settings.isAutoSwitchEnabled)

        if settings.isPaused {
            Button("Resume Auto Switch") { settings.resume() }
        } else {
            Button("Pause for 5 Minutes") { settings.pause(for: 5 * 60) }
        }

        Divider()

        Button("Convert Selected Text") { state.engine.convertSelection() }
            .keyboardShortcut(.space, modifiers: [.option])
        Button("Convert Last Word") { state.keyboardMonitor.convertLastWord() }
            .keyboardShortcut(.space, modifiers: [.option, .command])
        if state.engine.lastCorrection != nil {
            Button {
                state.engine.undoLastCorrection()
            } label: {
                Label("Undo Last Correction", systemImage: "arrow.uturn.backward")
            }
            .keyboardShortcut("z", modifiers: .command)
        }

        Divider()

        Button("Settings…") { SettingsWindowController.shared.show(state: state) }

        Divider()

        Button("About QuarkSwitch") {
            AboutWindowController.shared.show()
        }
        Button("Quit QuarkSwitch") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}

@MainActor
final class SettingsNavigation: ObservableObject {
    static let shared = SettingsNavigation()
    @Published var requestedSection: SettingsSection = .general
}
