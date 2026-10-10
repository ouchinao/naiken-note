import Domain
import Foundation
import WidgetKit

struct UpcomingVisitProvider: TimelineProvider {
    func placeholder(in _: Context) -> UpcomingVisitEntry {
        return UpcomingVisitEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (UpcomingVisitEntry) -> Void) {
        if context.isPreview {
            completion(UpcomingVisitEntry.placeholder)
        } else {
            completion(UpcomingVisitEntry(date: Date(), visits: upcomingVisits(after: Date())))
        }
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<UpcomingVisitEntry>) -> Void) {
        let now = Date()
        let visits = upcomingVisits(after: now)
        let entry = UpcomingVisitEntry(date: now, visits: visits)
        // 決まった間隔で読み直さないのは、表示が変わるのは次の内見の時刻を過ぎたときだけで、更新できる回数にも上限があるため
        let policy: TimelineReloadPolicy = visits.first.map { .after($0.visitAt) } ?? .never
        completion(Timeline(entries: [entry], policy: policy))
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
