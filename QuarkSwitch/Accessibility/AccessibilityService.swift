import AppKit
import ApplicationServices

final class AccessibilityService {
    static let shared = AccessibilityService()

    private init() {}

    var isTrusted: Bool { AXIsProcessTrusted() }

    var frontmostBundleIdentifier: String? {
        NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    }

    func requestTrustPrompt() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    func focusedElement() -> AXUIElement? {
        let system = AXUIElementCreateSystemWide()
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(system, kAXFocusedUIElementAttribute as CFString, &value) == .success,
              let value else { return nil }
        return (value as! AXUIElement)
    }

    func isSecureInputFocused() -> Bool {
        guard let element = focusedElement() else { return true }
        let role = stringAttribute(kAXRoleAttribute as CFString, of: element)
        let subrole = stringAttribute(kAXSubroleAttribute as CFString, of: element)
        if subrole == (kAXSecureTextFieldSubrole as String) { return true }
        if role == (kAXTextFieldRole as String), subrole?.localizedCaseInsensitiveContains("secure") == true { return true }

        var protectedValue: CFTypeRef?
        let protectedAttribute = "AXProtectedContent" as CFString
        if AXUIElementCopyAttributeValue(element, protectedAttribute, &protectedValue) == .success,
           let protectedValue = protectedValue as? Bool, protectedValue {
            return true
        }
        return false
    }

    func selectedText() -> String? {
        guard let element = focusedElement() else { return nil }
        return stringAttribute(kAXSelectedTextAttribute as CFString, of: element)
    }

    @discardableResult
    func replaceSelectedText(with text: String) -> Bool {
        guard let element = focusedElement(), !isSecureInputFocused() else { return false }
        return AXUIElementSetAttributeValue(element, kAXSelectedTextAttribute as CFString, text as CFTypeRef) == .success
    }

    /// Replaces only the short range immediately before the caret. This is the
    /// preferred correction path because it does not synthesize keystrokes and
    /// never reads the surrounding field value.
    func replaceTextBeforeCaret(utf16Length: Int, with replacement: String) -> Bool {
        guard utf16Length > 0, let element = focusedElement(), !isSecureInputFocused() else { return false }

        var currentRangeReference: CFTypeRef?
        guard AXUIElementCopyAttributeValue(
            element,
            kAXSelectedTextRangeAttribute as CFString,
            &currentRangeReference
        ) == .success,
        let currentRangeReference,
        CFGetTypeID(currentRangeReference) == AXValueGetTypeID() else { return false }

        var currentRange = CFRange()
        guard AXValueGetValue(currentRangeReference as! AXValue, .cfRange, &currentRange),
              currentRange.length == 0,
              currentRange.location >= utf16Length else { return false }

        var replacementRange = CFRange(
            location: currentRange.location - utf16Length,
            length: utf16Length
        )
        guard let replacementRangeValue = AXValueCreate(.cfRange, &replacementRange),
              AXUIElementSetAttributeValue(
                element,
                kAXSelectedTextRangeAttribute as CFString,
                replacementRangeValue
              ) == .success else { return false }

        let result = AXUIElementSetAttributeValue(
            element,
            kAXSelectedTextAttribute as CFString,
            replacement as CFTypeRef
        )
        if result != .success {
            _ = AXUIElementSetAttributeValue(
                element,
                kAXSelectedTextRangeAttribute as CFString,
                currentRangeReference
            )
        }
        return result == .success
    }

    func textBeforeCaretEnds(with suffix: String) -> Bool? {
        guard let element = focusedElement(), !isSecureInputFocused() else { return false }

        var rangeReference: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, &rangeReference) == .success,
              let rangeReference, CFGetTypeID(rangeReference) == AXValueGetTypeID() else { return nil }
        var range = CFRange()
        guard AXValueGetValue(rangeReference as! AXValue, .cfRange, &range) else { return nil }
        let suffixLength = suffix.utf16.count
        guard range.location >= suffixLength else { return false }

        var precedingRange = CFRange(location: range.location - suffixLength, length: suffixLength)
        guard let rangeValue = AXValueCreate(.cfRange, &precedingRange) else { return nil }
        var snippetReference: CFTypeRef?
        guard AXUIElementCopyParameterizedAttributeValue(
            element,
            kAXStringForRangeParameterizedAttribute as CFString,
            rangeValue,
            &snippetReference
        ) == .success else { return nil }
        return (snippetReference as? String) == suffix
    }

    private func stringAttribute(_ attribute: CFString, of element: AXUIElement) -> String? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, attribute, &value) == .success else { return nil }
        return value as? String
    }
}
