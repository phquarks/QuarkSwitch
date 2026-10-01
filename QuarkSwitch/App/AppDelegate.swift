import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        Task { @MainActor in
            let state = AppState.shared
            state.permissions.refresh()
            state.keyboardMonitor.start()
            if !state.settings.hasCompletedOnboarding {
                OnboardingWindowController.shared.show(state: state)
            } else if !state.settings.showMenuBarIcon {
                SettingsWindowController.shared.show(state: state)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        Task { @MainActor in AppState.shared.keyboardMonitor.stop() }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            Task { @MainActor in SettingsWindowController.shared.show(state: AppState.shared) }
        }
        return true
    }
}

@MainActor
final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    static let shared = SettingsWindowController()

    private init() { super.init(window: nil) }
    required init?(coder: NSCoder) { nil }

    func show(state: AppState) {
        if window == nil {
            let window = NSWindow(contentViewController: NSHostingController(rootView: SettingsRootView(state: state)))
            window.title = "QuarkSwitch Settings"
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.setContentSize(NSSize(width: 820, height: 590))
            window.center()
            window.delegate = self
            self.window = window
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}

@MainActor
final class OnboardingWindowController: NSWindowController, NSWindowDelegate {
    static let shared = OnboardingWindowController()

    private init() { super.init(window: nil) }
    required init?(coder: NSCoder) { nil }

    func show(state: AppState) {
        if window == nil {
            let content = OnboardingView(state: state) { [weak self] in self?.close() }
            let window = NSWindow(contentViewController: NSHostingController(rootView: content))
            window.title = "Welcome to QuarkSwitch"
            window.styleMask = [.titled, .closable, .miniaturizable, .fullSizeContentView]
            window.titlebarAppearsTransparent = true
            window.setContentSize(NSSize(width: 620, height: 520))
            window.center()
            window.delegate = self
            self.window = window
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
