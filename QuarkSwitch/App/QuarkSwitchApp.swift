import SwiftUI

// THESIS: QuarkSwitch is an invisible bilingual proofreader, not a dashboard of feature cards.
// OWN-WORLD: Native macOS graphite surfaces, system accent, hairline divisions, compact controls, and direct status language.
// STORY: Grant two explicit permissions, let correction run quietly, and retain immediate manual control and Undo.
// FIRST VIEWPORT: A centered input-cursor mark leads one promise and one privacy explanation; Continue remains the sole action.
// FORM: Redline editor, grounded direction 3, seed 4febd1bf.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, and DESIGN.md

@main
struct QuarkSwitchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var state = AppState.shared

    var body: some Scene {
        MenuBarExtra(isInserted: Binding(
            get: { state.settings.showMenuBarIcon },
            set: { state.settings.showMenuBarIcon = $0 }
        )) {
            MenuBarContent(state: state)
        } label: {
            Image(systemName: state.operationalStatus.systemImage)
                .accessibilityLabel("QuarkSwitch: \(state.operationalStatus.title)")
        }
        .menuBarExtraStyle(.menu)
    }
}
