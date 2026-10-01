import Foundation

struct WordAnalyzer {
    private let protectedTechnicalWords: Set<String> = [
        "npm", "npx", "sudo", "git", "github", "localhost", "swift", "swiftui",
        "chatgpt", "openai", "codex", "macbook", "xcode", "json", "http", "https",
        "api", "ssh", "docker", "python", "java", "node", "sql"
    ]

    func shouldAnalyze(_ word: String, exceptions: Set<String>) -> Bool {
        let normalized = word.lowercased()
        guard word.count >= 3, word.count <= 32 else { return false }
        guard !exceptions.contains(normalized), !protectedTechnicalWords.contains(normalized) else { return false }
        guard word.rangeOfCharacter(from: .decimalDigits) == nil else { return false }
        guard !word.contains(where: { "@/:\\=+_#&?".contains($0) }) else { return false }
        guard !looksLikeDomainOrEmail(word), !looksLikeIPAddress(word), !looksLikePath(word) else { return false }
        guard !looksLikeCode(word), !looksLikeAbbreviation(word) else { return false }

        let allowed = CharacterSet.letters.union(CharacterSet(charactersIn: "-'’`[]{};,<>."))
        guard word.unicodeScalars.allSatisfy(allowed.contains),
              let converted = LayoutConverter().convertAutomatically(word)?.text else { return false }
        let lexical = CharacterSet.letters.union(CharacterSet(charactersIn: "-'"))
        return converted.unicodeScalars.allSatisfy(lexical.contains)
    }

    private func looksLikeDomainOrEmail(_ word: String) -> Bool {
        word.contains("@") || word.hasPrefix("www.") ||
            word.range(of: #"^[A-Za-z0-9-]+\.(com|org|net|io|dev|app|ru|kz)$"#,
                       options: [.regularExpression, .caseInsensitive]) != nil
    }

    private func looksLikeIPAddress(_ word: String) -> Bool {
        word.range(of: #"^\d{1,3}(\.\d{1,3}){3}$"#, options: .regularExpression) != nil
    }

    private func looksLikePath(_ word: String) -> Bool {
        word.hasPrefix("/") || word.hasPrefix("~") || word.contains("\\")
    }

    private func looksLikeCode(_ word: String) -> Bool {
        let hasLower = word.contains(where: \Character.isLowercase)
        let hasUpper = word.contains(where: \Character.isUppercase)
        let internalUppercase = word.dropFirst().contains(where: \Character.isUppercase)
        return (hasLower && hasUpper && internalUppercase) || word.contains("_")
    }

    private func looksLikeAbbreviation(_ word: String) -> Bool {
        word.count <= 6 && word.allSatisfy { !$0.isLetter || $0.isUppercase }
    }
}
