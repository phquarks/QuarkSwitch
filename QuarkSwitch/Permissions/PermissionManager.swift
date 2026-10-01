import AppKit
import ApplicationServices
import Combine

@MainActor
final class PermissionManager: ObservableObject {
    static let shared = PermissionManager()

    @Published private(set) var hasAccessibility = AXIsProcessTrusted()
    @Published private(set) var hasInputMonitoring = CGPreflightListenEventAccess()

    var allGranted: Bool { hasAccessibility && hasInputMonitoring }

    private var timer: Timer?

    private init() {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func refresh() {
        hasAccessibility = AXIsProcessTrusted()
        hasInputMonitoring = CGPreflightListenEventAccess()
    }

    func requestAccessibility() {
        AccessibilityService.shared.requestTrustPrompt()
        openPrivacyPane(anchor: "Privacy_Accessibility")
    }

    func requestInputMonitoring() {
        _ = CGRequestListenEventAccess()
        openPrivacyPane(anchor: "Privacy_ListenEvent")
    }

    func openPrivacyPane(anchor: String) {
        let candidates = [
            "x-apple.systempreferences:com.apple.preference.security?\(anchor)",
            "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?\(anchor)"
        ]
        for candidate in candidates {
            guard let url = URL(string: candidate) else { continue }
            if NSWorkspace.shared.open(url) { break }
        }
    }
}
