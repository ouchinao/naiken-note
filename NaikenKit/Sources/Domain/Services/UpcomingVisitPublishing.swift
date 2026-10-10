import Foundation

public protocol UpcomingVisitPublishing: Sendable {
    /// 次の内見予定をウィジェットに渡す
    func publish(_ visits: [UpcomingVisit]) async
}
