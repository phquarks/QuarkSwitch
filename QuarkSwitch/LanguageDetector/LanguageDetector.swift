import Foundation
import AppKit
import NaturalLanguage

final class LanguageDetector {
    private let converter: LayoutConverter
    private lazy var spellingLanguages: [String] = NSSpellChecker.shared.availableLanguages

    private let englishWords: Set<String> = [
        "about", "after", "again", "all", "also", "and", "another", "are", "because", "been",
        "before", "between", "but", "can", "come", "could", "day", "did", "do", "does", "done",
        "down", "each", "even", "every", "first", "for", "from", "get", "give", "good", "great",
        "had", "has", "have", "hello", "help", "here", "home", "how", "into", "just", "know",
        "last", "like", "look", "make", "many", "may", "more", "most", "much", "need", "new",
        "next", "not", "now", "one", "only", "other", "our", "out", "please", "right", "same",
        "see", "should", "some", "still", "take", "than", "thank", "that", "the", "their", "them",
        "then", "there", "these", "they", "thing", "think", "this", "time", "today", "two", "use",
        "very", "want", "was", "way", "we", "well", "were", "what", "when", "where", "which",
        "who", "will", "with", "work", "world", "would", "write", "yes", "you", "your"
    ]

    private let russianWords: Set<String> = [
        "без", "больше", "будет", "бы", "был", "была", "были", "быть", "вам", "вас", "ваш",
        "вот", "все", "всего", "вы", "где", "да", "давай", "даже", "два", "для", "день", "до",
        "его", "если", "есть", "еще", "же", "здесь", "или", "как", "когда", "который", "кто",
        "ли", "мне", "может", "можно", "мой", "мы", "на", "надо", "наш", "не", "нет", "но",
        "новый", "ну", "он", "она", "они", "оно", "от", "очень", "первый", "по", "под", "пока",
        "после", "почему", "привет", "при", "про", "просто", "работа", "раз", "сейчас", "спасибо",
        "так", "также", "там", "тебя", "теперь", "то", "тогда", "только", "тут", "ты", "уже",
        "хорошо", "хочу", "чем", "что", "чтобы", "это", "этот", "я"
    ]

    private let englishNGrams: Set<String> = [
        "th", "he", "in", "er", "an", "re", "on", "at", "en", "nd", "ti", "es", "or", "te",
        "of", "ed", "is", "it", "al", "ar", "st", "to", "nt", "ng", "se", "ha", "as", "ou",
        "io", "le", "ve", "co", "me", "de", "hi", "ri", "ro", "ic", "ne", "ea"
    ]

    private let russianNGrams: Set<String> = [
        "ст", "но", "то", "на", "ен", "ов", "ни", "ра", "во", "ко", "ро", "по", "ос", "го",
        "ал", "ли", "ер", "от", "пр", "та", "ет", "ло", "ре", "ол", "ка", "ит", "ор", "те",
        "ть", "де", "ла", "не", "ри", "ва", "об", "че", "ск", "ак", "ил", "тр"
    ]

    init(converter: LayoutConverter = LayoutConverter()) {
        self.converter = converter
    }

    func evaluate(_ original: String) -> DetectionResult {
        guard let candidate = converter.convertAutomatically(original) else {
            return DetectionResult(original: original, converted: original, classification: .unknown,
                                   direction: nil, originalScore: 0, convertedScore: 0)
        }

        let originalLanguage: NLLanguage = candidate.direction == .englishToRussian ? .english : .russian
        let convertedLanguage: NLLanguage = candidate.direction == .englishToRussian ? .russian : .english
        let originalScore = score(original, as: originalLanguage)
        let convertedScore = score(candidate.text, as: convertedLanguage)
        let classification: LanguageClassification

        if convertedScore > originalScore {
            classification = candidate.direction == .englishToRussian
                ? .wrongEnglishLayoutIntendedRussian
                : .wrongRussianLayoutIntendedEnglish
        } else {
            classification = originalLanguage == .english ? .english : .russian
        }

        return DetectionResult(original: original, converted: candidate.text,
                               classification: classification, direction: candidate.direction,
                               originalScore: originalScore, convertedScore: convertedScore)
    }

    func evaluateToken(_ token: String) -> DetectionResult {
        var best = evaluate(token)
        var stem = token
        var suffix = ""
        // A final dot/comma may be sentence punctuation or a mistyped ю/б.
        // Compare both interpretations instead of dropping the key blindly.
        while let last = stem.last, ".,;".contains(last), suffix.count < 3 {
            suffix.insert(stem.removeLast(), at: suffix.startIndex)
            guard WordAnalyzer().shouldAnalyze(stem, exceptions: []) else { continue }
            let candidate = evaluate(stem)
            if candidate.convertedScore > best.convertedScore && candidate.improvement > best.improvement {
                best = DetectionResult(
                    original: token, converted: candidate.converted + suffix,
                    classification: candidate.classification, direction: candidate.direction,
                    originalScore: candidate.originalScore, convertedScore: candidate.convertedScore
                )
            }
        }
        return best
    }

    private func score(_ word: String, as language: NLLanguage) -> Double {
        let normalized = word.lowercased()
        let dictionary = language == .english ? englishWords : russianWords
        let ngrams = language == .english ? englishNGrams : russianNGrams
        // The system dictionaries cover inflections and thousands of words
        // beyond the small high-frequency seed lists, without a server.
        var score = dictionary.contains(normalized) || isCorrectlySpelled(normalized, language: language) ? 8.0 : 0.0

        let pairs = zip(normalized, normalized.dropFirst()).map { String([$0, $1]) }
        if !pairs.isEmpty {
            let matches = pairs.filter(ngrams.contains).count
            score += Double(matches) / Double(pairs.count) * 4.0
        }

        let recognizer = NLLanguageRecognizer()
        recognizer.processString(normalized)
        let confidence = recognizer.languageHypotheses(withMaximum: 2)[language] ?? 0
        score += confidence * 3.0

        score -= unlikelySequencePenalty(normalized, language: language)
        return score
    }

    private func isCorrectlySpelled(_ word: String, language: NLLanguage) -> Bool {
        guard word.contains(where: \.isLetter),
              word.allSatisfy({ $0.isLetter || $0 == "-" || $0 == "'" }) else { return false }
        let prefix = language == .russian ? "ru" : "en"
        guard let identifier = spellingLanguages.first(where: { $0.hasPrefix(prefix) }) else { return false }
        var wordCount = 0
        let misspelling = NSSpellChecker.shared.checkSpelling(
            of: word, startingAt: 0, language: identifier, wrap: false,
            inSpellDocumentWithTag: 0, wordCount: &wordCount
        )
        return wordCount > 0 && misspelling.location == NSNotFound
    }

    private func unlikelySequencePenalty(_ word: String, language: NLLanguage) -> Double {
        if language == .english {
            let noVowels = !word.contains(where: { "aeiouy".contains($0) })
            let unlikely = ["ghb", "hbd", "bdt", "dtn", "jjj", "qq", "zx"]
            return (noVowels ? 2.0 : 0) + (unlikely.contains(where: word.contains) ? 3.0 : 0)
        }
        let noVowels = !word.contains(where: { "аеёиоуыэюя".contains($0) })
        let unlikely = ["ъъ", "ыы", "ьь", "щщ", "дщ", "жэ"]
        return (noVowels ? 2.0 : 0) + (unlikely.contains(where: word.contains) ? 2.5 : 0)
    }
}
