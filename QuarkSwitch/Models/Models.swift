import Foundation

enum ConversionDirection: String, Codable, CaseIterable, Identifiable {
    case englishToRussian
    case russianToEnglish

    var id: String { rawValue }

    var title: String {
        switch self {
        case .englishToRussian: "EN → RU"
        case .russianToEnglish: "RU → EN"
        }
    }
}

enum LanguageClassification: String, Codable {
    case english
    case russian
    case wrongEnglishLayoutIntendedRussian
    case wrongRussianLayoutIntendedEnglish
    case unknown
}

struct DetectionResult: Equatable {
    let original: String
    let converted: String
    let classification: LanguageClassification
    let direction: ConversionDirection?
    let originalScore: Double
    let convertedScore: Double

    var improvement: Double { convertedScore - originalScore }
}

struct CorrectionSnapshot {
    let original: String
    let replacement: String
    let delimiter: String
    let direction: ConversionDirection
    let bundleIdentifier: String?
    let timestamp: Date
}

struct BoundarySnapshot {
    let word: String
    let delimiter: String
    let bundleIdentifier: String?
    let timestamp: Date
}

struct DailyStatistics: Codable, Identifiable {
    let day: String
    var englishToRussian: Int
    var russianToEnglish: Int
    var undoCount: Int

    var id: String { day }
    var corrections: Int { englishToRussian + russianToEnglish }
}

enum SettingsSection: String, CaseIterable, Identifiable {
    case general = "General"
    case autoSwitch = "Auto Switch"
    case hotkeys = "Hotkeys"
    case languages = "Languages"
    case exceptions = "Exceptions"
    case applications = "Applications"
    case privacy = "Privacy"
    case statistics = "Statistics"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .general: "gearshape"
        case .autoSwitch: "arrow.left.arrow.right"
        case .hotkeys: "command"
        case .languages: "character.book.closed"
        case .exceptions: "text.badge.xmark"
        case .applications: "app.badge.checkmark"
        case .privacy: "hand.raised"
        case .statistics: "chart.bar.xaxis"
        }
    }
}

enum OperationalStatus: Equatable {
    case active
    case paused
    case disabled
    case permissionsRequired
    case monitorUnavailable

    var title: String {
        switch self {
        case .active: "Auto Switch is active"
        case .paused: "Auto Switch is paused"
        case .disabled: "Auto Switch is off"
        case .permissionsRequired: "Permissions required"
        case .monitorUnavailable: "Input monitor is unavailable"
        }
    }

    var systemImage: String {
        switch self {
        case .active: "character.cursor.ibeam"
        case .paused: "pause.circle"
        case .disabled: "power.circle"
        case .permissionsRequired: "exclamationmark.shield"
        case .monitorUnavailable: "exclamationmark.triangle"
        }
    }
}
