import ApplicationServices
import Foundation

final class TextReplacementService {
    static let syntheticEventMarker: Int64 = 0x515541524B

    private let accessibility: AccessibilityService

    init(accessibility: AccessibilityService = .shared) {
        self.accessibility = accessibility
    }

    @discardableResult
    func replacePreviousText(characterCount: Int, with replacement: String) -> Bool {
        guard characterCount > 0, !accessibility.isSecureInputFocused() else { return false }
        if accessibility.replaceTextBeforeCaret(utf16Length: characterCount, with: replacement) {
            return true
        }
        for _ in 0..<characterCount {
            guard postKey(virtualKey: 51, isDown: true), postKey(virtualKey: 51, isDown: false) else { return false }
        }
        return postUnicode(replacement)
    }

    func convertSelection(using converter: LayoutConverter) -> Bool {
        guard !accessibility.isSecureInputFocused(),
              let selected = accessibility.selectedText(), !selected.isEmpty,
              let converted = converter.convertAutomatically(selected)?.text,
              converted != selected else { return false }
        return accessibility.replaceSelectedText(with: converted)
    }

    private func postKey(virtualKey: CGKeyCode, isDown: Bool) -> Bool {
        guard let event = CGEvent(keyboardEventSource: nil, virtualKey: virtualKey, keyDown: isDown) else { return false }
        event.setIntegerValueField(.eventSourceUserData, value: Self.syntheticEventMarker)
        event.post(tap: .cghidEventTap)
        return true
    }

    private func postUnicode(_ text: String) -> Bool {
        let utf16 = Array(text.utf16)
        guard !utf16.isEmpty else { return false }
        for chunkStart in stride(from: 0, to: utf16.count, by: 20) {
            let chunk = Array(utf16[chunkStart..<min(chunkStart + 20, utf16.count)])
            guard let down = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true),
                  let up = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: false) else { return false }
            down.setIntegerValueField(.eventSourceUserData, value: Self.syntheticEventMarker)
            up.setIntegerValueField(.eventSourceUserData, value: Self.syntheticEventMarker)
            down.keyboardSetUnicodeString(stringLength: chunk.count, unicodeString: chunk)
            up.keyboardSetUnicodeString(stringLength: chunk.count, unicodeString: chunk)
            down.post(tap: .cghidEventTap)
            up.post(tap: .cghidEventTap)
        }
        return true
    }
}
