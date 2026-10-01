import Combine
import Foundation

struct KnownApplication: Identifiable, Hashable {
    let name: String
    let bundleIdentifier: String
    let systemImage: String
    var id: String { bundleIdentifier }
}

@MainActor
final class ApplicationFilter: ObservableObject {
    static let shared = ApplicationFilter()

    static let knownApplications = [
        KnownApplication(name: "Terminal", bundleIdentifier: "com.apple.Terminal", systemImage: "terminal"),
        KnownApplication(name: "iTerm2", bundleIdentifier: "com.googlecode.iterm2", systemImage: "terminal.fill"),
        KnownApplication(name: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", systemImage: "hammer"),
        KnownApplication(name: "Visual Studio Code", bundleIdentifier: "com.microsoft.VSCode", systemImage: "chevron.left.forwardslash.chevron.right"),
        KnownApplication(name: "PyCharm", bundleIdentifier: "com.jetbrains.pycharm", systemImage: "chevron.left.forwardslash.chevron.right")
    ]

    private let defaults = UserDefaults.standard
    private let key = "applications.disabledBundleIdentifiers"
    private let defaultsVersionKey = "applications.defaultsVersion"

    @Published private(set) var disabledBundleIdentifiers: Set<String>

    private init() {
        if let stored = defaults.stringArray(forKey: key) {
            disabledBundleIdentifiers = Set(stored)
        } else {
            disabledBundleIdentifiers = ["com.apple.Terminal", "com.googlecode.iterm2"]
        }

        // Version 1 mistakenly disabled IDEs out of the box. They are supported
        // targets and must remain enabled unless the user explicitly opts out.
        if defaults.integer(forKey: defaultsVersionKey) < 2 {
            disabledBundleIdentifiers.subtract([
                "com.apple.dt.Xcode",
                "com.microsoft.VSCode",
                "com.jetbrains.pycharm"
            ])
            defaults.set(2, forKey: defaultsVersionKey)
        }
        persist()
    }

    func isAllowed(_ bundleIdentifier: String?) -> Bool {
        guard let bundleIdentifier else { return true }
        return !disabledBundleIdentifiers.contains(bundleIdentifier)
    }

    func setDisabled(_ disabled: Bool, bundleIdentifier: String) {
        if disabled {
            disabledBundleIdentifiers.insert(bundleIdentifier)
        } else {
            disabledBundleIdentifiers.remove(bundleIdentifier)
        }
        persist()
    }

    func add(bundleIdentifier: String) {
        let trimmed = bundleIdentifier.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.contains(".") else { return }
        disabledBundleIdentifiers.insert(trimmed)
        persist()
    }

    func remove(bundleIdentifier: String) {
        disabledBundleIdentifiers.remove(bundleIdentifier)
        persist()
    }

    private func persist() {
        defaults.set(Array(disabledBundleIdentifiers).sorted(), forKey: key)
    }
}
