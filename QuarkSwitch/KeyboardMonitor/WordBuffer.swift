import Foundation

/// Layout punctuation is part of a token: `[`, `;`, `'`, `,`, `.`, and
/// `` ` `` can be Russian letters. Keep it until an unambiguous boundary.
struct WordBuffer {
    private(set) var text = ""
    private var overflowed = false

    mutating func append(_ input: String) -> (word: String, delimiter: String)? {
        guard input.count == 1, let character = input.first else {
            clear()
            return nil
        }
        if character.isWhitespace || "!?\"():".contains(character) {
            let word = overflowed ? "" : text
            clear()
            return word.isEmpty ? nil : (word, input)
        }
        // Preserve the whole token so URL/email/path protection cannot be
        // bypassed by treating their punctuation as a new word boundary.
        guard !overflowed else { return nil }
        guard text.count < 64 else {
            text = ""
            overflowed = true
            return nil
        }
        text.append(character)
        return nil
    }

    mutating func backspace() {
        if !text.isEmpty { text.removeLast() }
    }

    mutating func clear() {
        text = ""
        overflowed = false
    }
}
