import Combine
import Foundation

@MainActor
final class StatisticsManager: ObservableObject {
    static let shared = StatisticsManager()

    private let defaults = UserDefaults.standard
    private let key = "statistics.daily.v1"
    private let calendar = Calendar.autoupdatingCurrent
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    @Published private(set) var days: [DailyStatistics] = []

    var today: DailyStatistics { aggregate(from: calendar.startOfDay(for: Date())) }

    var thisWeek: DailyStatistics {
        let start = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? calendar.startOfDay(for: Date())
        return aggregate(from: start)
    }

    private init() {
        guard let data = defaults.data(forKey: key), let decoded = try? decoder.decode([DailyStatistics].self, from: data) else { return }
        days = decoded
        prune()
    }

    func recordCorrection(direction: ConversionDirection) {
        mutateToday { item in
            switch direction {
            case .englishToRussian: item.englishToRussian += 1
            case .russianToEnglish: item.russianToEnglish += 1
            }
        }
    }

    func recordUndo() {
        mutateToday { $0.undoCount += 1 }
    }

    func reset() {
        days = []
        persist()
    }

    private func mutateToday(_ change: (inout DailyStatistics) -> Void) {
        let key = dayKey(Date())
        if let index = days.firstIndex(where: { $0.day == key }) {
            change(&days[index])
        } else {
            var item = DailyStatistics(day: key, englishToRussian: 0, russianToEnglish: 0, undoCount: 0)
            change(&item)
            days.append(item)
        }
        prune()
        persist()
    }

    private func aggregate(from start: Date) -> DailyStatistics {
        let startKey = dayKey(start)
        let items = days.filter { $0.day >= startKey }
        return DailyStatistics(day: startKey,
                               englishToRussian: items.reduce(0) { $0 + $1.englishToRussian },
                               russianToEnglish: items.reduce(0) { $0 + $1.russianToEnglish },
                               undoCount: items.reduce(0) { $0 + $1.undoCount })
    }

    private func prune() {
        guard let cutoff = calendar.date(byAdding: .day, value: -90, to: Date()) else { return }
        let cutoffKey = dayKey(cutoff)
        days.removeAll { $0.day < cutoffKey }
    }

    private func dayKey(_ date: Date) -> String {
        date.formatted(.iso8601.year().month().day())
    }

    private func persist() {
        if let data = try? encoder.encode(days) {
            defaults.set(data, forKey: key)
        }
    }
}
