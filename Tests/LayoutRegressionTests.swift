import AppKit
import Foundation

@main
struct LayoutRegressionTests {
    static func main() {
        let converter = LayoutConverter()
        let analyzer = WordAnalyzer()
        let detector = LanguageDetector()
        let threshold = 1.6 + 0.72 * 2.8

        for (typed, expected) in [
            ("[jhjij", "хорошо"), ("ghbdtn", "привет"),
            (";bpym", "жизнь"), (",eltn", "будет"),
            ("cxtcnmt", "счестье"), // mapping only, intentionally misspelled
            ("руддщ", "hello")
        ] {
            precondition(converter.convertAutomatically(typed)?.text == expected, typed)
            var buffer = WordBuffer()
            for character in typed { precondition(buffer.append(String(character)) == nil) }
            let boundary = buffer.append(" ")
            precondition(boundary?.word == typed && boundary?.delimiter == " ", typed)
            precondition(buffer.text.isEmpty)
        }

        for expected in ["хорошо", "жизнь", "люблю", "здравствуйте", "клавиатура", "проверка", "сегодня", "приложение", "работает", "человек", "документ", "возможность"] {
            let typed = converter.convert(expected, direction: .russianToEnglish)
            precondition(analyzer.shouldAnalyze(typed, exceptions: []), typed)
            let result = detector.evaluate(typed)
            print("\(typed) → \(result.converted): \(result.improvement)")
            precondition(result.converted == expected && result.improvement >= threshold, expected)
        }

        for token in ["hello", "world", "keyboard", "document", "application", "beautiful"] {
            precondition(detector.evaluate(token).improvement < threshold, token)
        }
        for (typed, expected) in [("ghbdtn.", "привет."), ("[jhjij,", "хорошо,"), ("k.,k.", "люблю")] {
            precondition(detector.evaluateToken(typed).converted == expected, typed)
        }
        for token in ["github.com", "admin@example.com", "npm", "sudo", "localhost", "192.168.1.1", "SwiftUI", "ChatGPT", "OpenAI", "/tmp/file", "foo_bar"] {
            precondition(!analyzer.shouldAnalyze(token, exceptions: []), token)
        }
        var address = WordBuffer()
        for character in "admin@example.com" { _ = address.append(String(character)) }
        precondition(address.append(" ")?.word == "admin@example.com")
        print("LAYOUT_REGRESSIONS_PASSED")
    }
}
