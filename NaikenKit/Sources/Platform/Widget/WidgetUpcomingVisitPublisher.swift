import Domain
import Foundation
import WidgetKit

/// ウィジェットに SwiftData のストアを開かせないのは、CloudKit と同期しているストアを別のプロセスから開かないようにするため
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
