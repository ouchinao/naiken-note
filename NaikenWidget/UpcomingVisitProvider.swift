import Domain
import Foundation
import WidgetKit

struct UpcomingVisitProvider: TimelineProvider {
    func placeholder(in _: Context) -> UpcomingVisitEntry {
        return .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (UpcomingVisitEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
        } else {
            let now = Date()
            completion(UpcomingVisitEntry(date: now, visits: upcomingVisits(after: now)))
        }
    }

    /// 内見の時刻を過ぎるたびに読み直して次の予定を出さないのは、読み直せる回数に上限があり、遅れると過ぎた内見を出し続けるため。
    /// 決まった間隔でも読み直さないのは、表示が変わるのは内見の時刻を過ぎたときだけなため
    func getTimeline(in _: Context, completion: @escaping (Timeline<UpcomingVisitEntry>) -> Void) {
        let now = Date()
        let visits = upcomingVisits(after: now)
        let switchTimes = [now] + visits.map(\.visitAt)
        let entries = switchTimes.map { date in
            return UpcomingVisitEntry(date: date, visits: visits.filter { $0.visitAt > date })
        }
        let policy: TimelineReloadPolicy = visits.last.map { .after($0.visitAt) } ?? .never
        completion(Timeline(entries: entries, policy: policy))
    }

    // MARK: - Private

    private func upcomingVisits(after date: Date) -> [UpcomingVisit] {
        guard let data = UserDefaults(suiteName: SharedStorage.appGroupID)?.data(forKey: SharedStorage.upcomingVisitsKey),
              let visits = try? UpcomingVisit.decode(data) else {
            return []
        }
        return visits.filter { $0.visitAt > date }
    }
}
