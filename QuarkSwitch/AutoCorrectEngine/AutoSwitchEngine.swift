import AppKit
import Combine
import Foundation

@MainActor
final class AutoSwitchEngine: ObservableObject {
    @Published private(set) var lastCorrection: CorrectionSnapshot?
    @Published private(set) var statusMessage = "Ready"

    private let settings: SettingsManager
    private let exceptions: ExceptionManager
    private let applicationFilter: ApplicationFilter
    private let statistics: StatisticsManager
    private let permissions: PermissionManager
    private let analyzer: WordAnalyzer
    private let detector: LanguageDetector
    private let converter: LayoutConverter
    private let replacement: TextReplacementService
    private let notifications: NotificationService

    init(settings: SettingsManager,
         exceptions: ExceptionManager,
         applicationFilter: ApplicationFilter,
         statistics: StatisticsManager,
         permissions: PermissionManager,
         converter: LayoutConverter = LayoutConverter()) {
        self.settings = settings
        self.exceptions = exceptions
        self.applicationFilter = applicationFilter
        self.statistics = statistics
        self.permissions = permissions
        self.converter = converter
        analyzer = WordAnalyzer()
        detector = LanguageDetector(converter: converter)
        replacement = TextReplacementService()
        notifications = NotificationService()
    }

    func processBoundary(_ snapshot: BoundarySnapshot) {
        guard settings.isOperational else {
            statusMessage = "Automatic correction is paused or off"
            return
        }
        guard permissions.allGranted else {
            statusMessage = "Permissions are required"
            return
        }
        guard applicationFilter.isAllowed(snapshot.bundleIdentifier) else {
            statusMessage = "Automatic correction is disabled for this app"
            return
        }
        guard analyzer.shouldAnalyze(snapshot.word, exceptions: exceptions.normalizedWords) else {
            statusMessage = "Protected or excluded token skipped"
            return
        }

        let result = detector.evaluateToken(snapshot.word)
        let requiredImprovement = 1.6 + settings.sensitivity * 2.8
        guard let direction = result.direction,
              result.classification == .wrongEnglishLayoutIntendedRussian ||
                result.classification == .wrongRussianLayoutIntendedEnglish,
              result.improvement >= requiredImprovement else {
            statusMessage = "No layout error detected"
            return
        }

        replace(snapshot.word, with: result.converted, delimiter: snapshot.delimiter,
                direction: direction, bundleIdentifier: snapshot.bundleIdentifier, automatic: true)
    }

    func convertSelection() {
        guard permissions.hasAccessibility else {
            statusMessage = "Accessibility permission is required"
            return
        }
        statusMessage = replacement.convertSelection(using: converter) ? "Selection converted" : "Select text to convert"
    }

    func convertLastWord(_ snapshot: BoundarySnapshot?) {
        guard let snapshot, Date().timeIntervalSince(snapshot.timestamp) < 12,
              applicationFilter.isAllowed(snapshot.bundleIdentifier),
              let converted = converter.convertAutomatically(snapshot.word), converted.text != snapshot.word else {
            statusMessage = "No recent word to convert"
            return
        }
        replace(snapshot.word, with: converted.text, delimiter: snapshot.delimiter,
                direction: converted.direction, bundleIdentifier: snapshot.bundleIdentifier, automatic: false)
    }

    func convertCurrentWord(_ word: String, bundleIdentifier: String?) {
        guard !word.isEmpty, let converted = converter.convertAutomatically(word), converted.text != word else { return }
        replace(word, with: converted.text, delimiter: "", direction: converted.direction,
                bundleIdentifier: bundleIdentifier, automatic: false)
    }

    func canUndo(in bundleIdentifier: String?) -> Bool {
        guard let lastCorrection else { return false }
        return Date().timeIntervalSince(lastCorrection.timestamp) < 8 &&
            lastCorrection.bundleIdentifier == bundleIdentifier
    }

    func undoLastCorrection() {
        guard let correction = lastCorrection, canUndo(in: AccessibilityService.shared.frontmostBundleIdentifier) else { return }
        let currentText = correction.replacement + correction.delimiter
        guard replacement.replacePreviousText(characterCount: currentText.count,
                                              with: correction.original + correction.delimiter) else {
            statusMessage = "Undo could not be sent"
            return
        }
        exceptions.learnFromUndo(correction.original)
        statistics.recordUndo()
        lastCorrection = nil
        statusMessage = "Correction undone"
    }

    private func replace(_ original: String, with converted: String, delimiter: String,
                         direction: ConversionDirection, bundleIdentifier: String?, automatic: Bool) {
        let typedText = original + delimiter
        guard replacement.replacePreviousText(characterCount: typedText.count, with: converted + delimiter) else {
            statusMessage = "Correction could not be sent"
            return
        }
        let pendingCorrection = automatic
            ? CorrectionSnapshot(original: original, replacement: converted,
                                 delimiter: delimiter, direction: direction,
                                 bundleIdentifier: bundleIdentifier, timestamp: Date())
            : nil
        statusMessage = "Correction sent"

        let expectedSuffix = converted + delimiter
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            guard let self else { return }
            guard AccessibilityService.shared.frontmostBundleIdentifier == bundleIdentifier else {
                self.lastCorrection = nil
                self.statusMessage = "Correction sent; result unverified"
                return
            }
            if AccessibilityService.shared.textBeforeCaretEnds(with: expectedSuffix) == true {
                if let pendingCorrection {
                    self.lastCorrection = pendingCorrection
                    DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
                        guard self?.lastCorrection?.timestamp == pendingCorrection.timestamp else { return }
                        self?.lastCorrection = nil
                    }
                }
                self.statistics.recordCorrection(direction: direction)
                self.notifications.correctionCompleted(settings: self.settings)
                self.statusMessage = automatic ? "Last word corrected" : "Text converted"
            } else {
                if automatic { self.lastCorrection = nil }
                self.statusMessage = "Correction sent; result unverified"
            }
        }
    }
}
