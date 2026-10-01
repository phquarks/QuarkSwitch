import AppKit
import ApplicationServices
import Combine

@MainActor
final class KeyboardMonitor: ObservableObject {
    @Published private(set) var isRunning = false
    @Published private(set) var currentWordLength = 0

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var buffer = WordBuffer()
    private(set) var lastBoundary: BoundarySnapshot?

    private let accessibility: AccessibilityService
    private let permissions: PermissionManager
    private let engine: AutoSwitchEngine

    init(accessibility: AccessibilityService = .shared,
         permissions: PermissionManager,
         engine: AutoSwitchEngine) {
        self.accessibility = accessibility
        self.permissions = permissions
        self.engine = engine
    }

    func start() {
        guard eventTap == nil, permissions.hasInputMonitoring else { return }
        let mask = (1 << CGEventType.keyDown.rawValue) |
                   (1 << CGEventType.tapDisabledByTimeout.rawValue) |
                   (1 << CGEventType.tapDisabledByUserInput.rawValue)
        let pointer = Unmanaged.passUnretained(self).toOpaque()
        guard let tap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                          place: .headInsertEventTap,
                                          options: .defaultTap,
                                          eventsOfInterest: CGEventMask(mask),
                                          callback: Self.callback,
                                          userInfo: pointer) else {
            isRunning = false
            return
        }
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        isRunning = true
    }

    func stop() {
        if let runLoopSource { CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes) }
        if let eventTap { CGEvent.tapEnable(tap: eventTap, enable: false) }
        runLoopSource = nil
        eventTap = nil
        clearBuffer()
        isRunning = false
    }

    func restartIfPossible() {
        stop()
        permissions.refresh()
        start()
    }

    func convertLastWord() {
        if !buffer.text.isEmpty {
            let word = buffer.text
            clearBuffer()
            engine.convertCurrentWord(word, bundleIdentifier: accessibility.frontmostBundleIdentifier)
        } else {
            engine.convertLastWord(lastBoundary)
        }
    }

    private static let callback: CGEventTapCallBack = { _, type, event, userInfo in
        guard let userInfo else { return Unmanaged.passUnretained(event) }
        let monitor = Unmanaged<KeyboardMonitor>.fromOpaque(userInfo).takeUnretainedValue()

        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap = monitor.eventTap { CGEvent.tapEnable(tap: tap, enable: true) }
            return Unmanaged.passUnretained(event)
        }
        if event.getIntegerValueField(.eventSourceUserData) == TextReplacementService.syntheticEventMarker {
            return Unmanaged.passUnretained(event)
        }
        return monitor.handle(event: event)
    }

    private func handle(event: CGEvent) -> Unmanaged<CGEvent>? {
        guard event.type == .keyDown else { return Unmanaged.passUnretained(event) }
        let flags = event.flags.intersection([.maskCommand, .maskControl, .maskAlternate, .maskShift])
        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        let bundleIdentifier = accessibility.frontmostBundleIdentifier

        if flags.contains(.maskAlternate), keyCode == 49 {
            if flags.contains(.maskCommand) {
                convertLastWord()
            } else {
                clearBuffer()
                engine.convertSelection()
            }
            return nil
        }

        if flags.contains(.maskCommand), keyCode == 6, engine.canUndo(in: bundleIdentifier) {
            engine.undoLastCorrection()
            clearBuffer()
            return nil
        }

        if flags.contains(.maskCommand) || flags.contains(.maskControl) {
            clearBuffer()
            return Unmanaged.passUnretained(event)
        }

        guard permissions.allGranted, !accessibility.isSecureInputFocused() else {
            clearBuffer()
            return Unmanaged.passUnretained(event)
        }

        if keyCode == 51 {
            buffer.backspace()
            currentWordLength = buffer.text.count
            return Unmanaged.passUnretained(event)
        }

        guard let text = unicodeString(from: event), !text.isEmpty else {
            clearBuffer()
            return Unmanaged.passUnretained(event)
        }

        if let boundary = buffer.append(text) {
            let snapshot = BoundarySnapshot(word: boundary.word, delimiter: boundary.delimiter,
                                            bundleIdentifier: bundleIdentifier, timestamp: Date())
            lastBoundary = snapshot
            DispatchQueue.main.asyncAfter(deadline: .now() + 12) { [weak self] in
                guard self?.lastBoundary?.timestamp == snapshot.timestamp else { return }
                self?.lastBoundary = nil
            }
            clearBuffer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
                self?.engine.processBoundary(snapshot)
            }
        }
        currentWordLength = buffer.text.count
        return Unmanaged.passUnretained(event)
    }

    private func unicodeString(from event: CGEvent) -> String? {
        var length = 0
        var buffer = [UniChar](repeating: 0, count: 8)
        event.keyboardGetUnicodeString(maxStringLength: buffer.count,
                                       actualStringLength: &length,
                                       unicodeString: &buffer)
        guard length > 0 else { return nil }
        return String(utf16CodeUnits: buffer, count: length)
    }

    private func clearBuffer() {
        buffer.clear()
        currentWordLength = 0
    }
}
