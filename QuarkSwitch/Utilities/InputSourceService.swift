import AppKit
import Combine

@MainActor
final class InputSourceService: ObservableObject {
    static let shared = InputSourceService()

    @Published private(set) var displayName = "Unknown"
    private var timer: Timer?

    private init() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func refresh() {
        guard let identifier = NSTextInputContext.current?.selectedKeyboardInputSource else {
            displayName = "Unknown"
            return
        }
        let lowered = identifier.lowercased()
        if lowered.contains("russian") || lowered.contains("ru") {
            displayName = "Russian"
        } else if lowered.contains("abc") || lowered.contains("us") || lowered.contains("english") {
            displayName = "English"
        } else {
            displayName = identifier.components(separatedBy: ".").last ?? identifier
        }
    }
}
