import Foundation

public protocol UpcomingVisitPublishing: Sendable {
    func publish(_ visits: [UpcomingVisit]) async
}
