import AppKit
import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    let settings = SettingsManager.shared
    let permissions = PermissionManager.shared
    let exceptions = ExceptionManager.shared
    let applicationFilter = ApplicationFilter.shared
    let statistics = StatisticsManager.shared
    let inputSource = InputSourceService.shared
    let hotkeys = HotKeyManager()
    let engine: AutoSwitchEngine
    let keyboardMonitor: KeyboardMonitor

    @Published private(set) var operationalStatus: OperationalStatus = .permissionsRequired

    private var cancellables: Set<AnyCancellable> = []
    private var statusTimer: Timer?

    private init() {
        engine = AutoSwitchEngine(settings: settings, exceptions: exceptions,
                                  applicationFilter: applicationFilter,
                                  statistics: statistics, permissions: permissions)
        keyboardMonitor = KeyboardMonitor(permissions: permissions, engine: engine)

        permissions.$hasInputMonitoring
            .combineLatest(permissions.$hasAccessibility)
            .sink { [weak self] input, accessibility in
                guard let self else { return }
                if input && accessibility { self.keyboardMonitor.start() }
                else { self.keyboardMonitor.stop() }
            }
            .store(in: &cancellables)

        settings.$showMenuBarIcon
            .removeDuplicates()
            .sink { visible in
                NSApp.setActivationPolicy(visible ? .accessory : .regular)
            }
            .store(in: &cancellables)

        settings.$isAutoSwitchEnabled
            .merge(with: settings.$pauseUntil.map { [weak self] _ in self?.settings.isAutoSwitchEnabled ?? false })
            .sink { [weak self] _ in self?.updateOperationalStatus() }
            .store(in: &cancellables)
        permissions.$hasAccessibility
            .merge(with: permissions.$hasInputMonitoring)
            .sink { [weak self] _ in self?.updateOperationalStatus() }
            .store(in: &cancellables)
        keyboardMonitor.$isRunning
            .sink { [weak self] _ in self?.updateOperationalStatus() }
            .store(in: &cancellables)

        statusTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.updateOperationalStatus() }
        }
        updateOperationalStatus()
    }

    private func updateOperationalStatus() {
        if !settings.isAutoSwitchEnabled { operationalStatus = .disabled }
        else if settings.isPaused { operationalStatus = .paused }
        else if !permissions.allGranted { operationalStatus = .permissionsRequired }
        else if !keyboardMonitor.isRunning { operationalStatus = .monitorUnavailable }
        else { operationalStatus = .active }
    }
}
