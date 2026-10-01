import AppKit
import SwiftUI

@MainActor
final class AboutWindowController: NSWindowController {
    static let shared = AboutWindowController()

    private init() {
        let window = NSWindow(contentViewController: NSHostingController(rootView: AboutView()))
        window.title = "About QuarkSwitch"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.appearance = NSAppearance(named: .darkAqua)
        window.isReleasedWhenClosed = false
        window.setContentSize(NSSize(width: 500, height: 510))
        window.center()
        super.init(window: window)
    }

    required init?(coder: NSCoder) { nil }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
