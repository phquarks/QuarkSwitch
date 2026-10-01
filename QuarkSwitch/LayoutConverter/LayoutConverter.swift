import Foundation

struct LayoutConverter {
    private static let englishRows = [
        "`qwertyuiop[]\\",
        "asdfghjkl;'",
        "zxcvbnm,./"
    ]

    private static let russianRows = [
        "ёйцукенгшщзхъ\\",
        "фывапролджэ",
        "ячсмитьбю."
    ]

    private static let shiftedEnglishRows = [
        "~QWERTYUIOP{}|",
        "ASDFGHJKL:\"",
        "ZXCVBNM<>?"
    ]

    private static let shiftedRussianRows = [
        "ЁЙЦУКЕНГШЩЗХЪ/",
        "ФЫВАПРОЛДЖЭ",
        "ЯЧСМИТЬБЮ,"
    ]

    private let englishToRussian: [Character: Character]
    private let russianToEnglish: [Character: Character]

    init() {
        var forward: [Character: Character] = [:]
        for (english, russian) in zip(Self.englishRows, Self.russianRows) {
            for (source, destination) in zip(english, russian) {
                forward[source] = destination
            }
        }
        for (english, russian) in zip(Self.shiftedEnglishRows, Self.shiftedRussianRows) {
            for (source, destination) in zip(english, russian) {
                forward[source] = destination
            }
        }
        let reverse = Dictionary(uniqueKeysWithValues: forward.map { ($0.value, $0.key) })
        forward["’"] = "э"
        englishToRussian = forward
        russianToEnglish = reverse
    }

    func convert(_ text: String, direction: ConversionDirection) -> String {
        let mapping = direction == .englishToRussian ? englishToRussian : russianToEnglish
        return String(text.map { mapping[$0] ?? $0 })
    }

    func convertAutomatically(_ text: String) -> (text: String, direction: ConversionDirection)? {
        let latinCount = text.unicodeScalars.filter { scalar in
            (0x0041...0x005A).contains(scalar.value) || (0x0061...0x007A).contains(scalar.value)
        }.count
        let cyrillicCount = text.unicodeScalars.filter { scalar in
            (0x0400...0x04FF).contains(scalar.value)
        }.count

        if latinCount > cyrillicCount {
            return (convert(text, direction: .englishToRussian), .englishToRussian)
        }
        if cyrillicCount > latinCount {
            return (convert(text, direction: .russianToEnglish), .russianToEnglish)
        }
        return nil
    }
}
