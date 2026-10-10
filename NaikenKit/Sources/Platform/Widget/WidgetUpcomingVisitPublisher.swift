import Domain
import Foundation
import WidgetKit

/// 次の内見予定を App Group の UserDefaults に書き、ウィジェットを更新する。
/// ウィジェットはSwiftDataのストアを開かず、ここに書いた内容だけを読む
public struct WidgetUpcomingVisitPublisher: UpcomingVisitPublishing {
    public init() {}

    public func publish(_ visits: [UpcomingVisit]) async {
        guard let defaults = UserDefaults(suiteName: SharedStorage.appGroupID),
              let data = try? UpcomingVisit.encode(visits) else {
            return
        }
        defaults.set(data, forKey: SharedStorage.upcomingVisitsKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
