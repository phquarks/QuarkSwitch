import Combine
import Foundation

@MainActor
final class ExceptionManager: ObservableObject {
    static let shared = ExceptionManager()

    private let defaults = UserDefaults.standard
    private let key = "learning.exceptions"

    @Published private(set) var words: [String] = []

    var normalizedWords: Set<String> { Set(words.map { $0.lowercased() }) }

    private init() {
        words = defaults.stringArray(forKey: key) ?? ["ChatGPT", "OpenAI", "Swift", "SwiftUI", "MacBook", "Codex"]
        persist()
    }

    func add(_ word: String) {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !normalizedWords.contains(trimmed.lowercased()) else { return }
        words.append(trimmed)
        words.sort { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        persist()
    }

    func remove(_ word: String) {
        words.removeAll { $0.caseInsensitiveCompare(word) == .orderedSame }
        persist()
    }

    func learnFromUndo(_ original: String) {
        add(original)
    }

    private func persist() {
        defaults.set(words, forKey: key)
    }
}
