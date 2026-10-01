import AppKit
import Combine
import ServiceManagement
import UserNotifications

@MainActor
final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private enum Key {
        static let autoSwitch = "settings.autoSwitch"
        static let sound = "settings.sound"
        static let notification = "settings.notification"
        static let menuIcon = "settings.menuIcon"
        static let sensitivity = "settings.sensitivity"
        static let pauseUntil = "settings.pauseUntil"
        static let onboarding = "settings.onboarding"
    }

    private let defaults = UserDefaults.standard

    @Published var isAutoSwitchEnabled: Bool { didSet { defaults.set(isAutoSwitchEnabled, forKey: Key.autoSwitch) } }
    @Published var playSound: Bool { didSet { defaults.set(playSound, forKey: Key.sound) } }
    @Published var showNotification: Bool { didSet { defaults.set(showNotification, forKey: Key.notification) } }
    @Published var showMenuBarIcon: Bool { didSet { defaults.set(showMenuBarIcon, forKey: Key.menuIcon) } }
    @Published var sensitivity: Double { didSet { defaults.set(sensitivity, forKey: Key.sensitivity) } }
    @Published var pauseUntil: Date? { didSet { defaults.set(pauseUntil, forKey: Key.pauseUntil) } }
    @Published private(set) var launchAtLogin = SMAppService.mainApp.status == .enabled
    @Published var launchAtLoginError: String?

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Key.onboarding) }
        set { defaults.set(newValue, forKey: Key.onboarding) }
    }

    var isPaused: Bool {
        guard let pauseUntil else { return false }
        return pauseUntil > Date()
    }

    var isOperational: Bool { isAutoSwitchEnabled && !isPaused }

    private init() {
        defaults.register(defaults: [
            Key.autoSwitch: true,
            Key.sound: false,
            Key.notification: false,
            Key.menuIcon: true,
            Key.sensitivity: 0.72
        ])
        isAutoSwitchEnabled = defaults.bool(forKey: Key.autoSwitch)
        playSound = defaults.bool(forKey: Key.sound)
        showNotification = defaults.bool(forKey: Key.notification)
        showMenuBarIcon = defaults.bool(forKey: Key.menuIcon)
        sensitivity = defaults.double(forKey: Key.sensitivity)
        pauseUntil = defaults.object(forKey: Key.pauseUntil) as? Date
    }

    func pause(for interval: TimeInterval) {
        pauseUntil = Date().addingTimeInterval(interval)
    }

    func resume() {
        pauseUntil = nil
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            launchAtLogin = enabled
            launchAtLoginError = nil
        } catch {
            launchAtLogin = SMAppService.mainApp.status == .enabled
            launchAtLoginError = error.localizedDescription
        }
    }

    func setNotificationsEnabled(_ enabled: Bool) {
        showNotification = enabled
        guard enabled else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [weak self] granted, _ in
            if !granted {
                Task { @MainActor in self?.showNotification = false }
            }
        }
    }
}
