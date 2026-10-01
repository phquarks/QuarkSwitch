import Combine
import Foundation

@MainActor
final class HotKeyManager: ObservableObject {
    enum Shortcut: String, CaseIterable, Identifiable {
        case convertSelection
        case convertLastWord

        var id: String { rawValue }
        var title: String { self == .convertSelection ? "Convert Selected Text" : "Convert Last Word" }
        var displayValue: String { self == .convertSelection ? "⌥ Space" : "⌥⌘ Space" }
    }

    let shortcuts = Shortcut.allCases

    // Shortcut interception lives in the single global event tap so the app never
    // installs a second keyboard observer or duplicates permission requirements.
}
