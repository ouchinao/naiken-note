import Domain
import Foundation
import WidgetKit

/// アプリ本体が App Group の UserDefaults に書いた内見予定を読む。SwiftDataのストアは開かない
struct UpcomingVisitProvider: TimelineProvider {
    func placeholder(in context: Context) -> UpcomingVisitEntry {
        return UpcomingVisitEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (UpcomingVisitEntry) -> Void) {
        if context.isPreview {
            completion(UpcomingVisitEntry.placeholder)
        } else {
            completion(UpcomingVisitEntry(date: Date(), visits: upcomingVisits(after: Date())))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UpcomingVisitEntry>) -> Void) {
        let now = Date()
        let visits = upcomingVisits(after: now)
        let entry = UpcomingVisitEntry(date: now, visits: visits)
        // 次の内見の時刻を過ぎたら、その次の予定に切り替える
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
