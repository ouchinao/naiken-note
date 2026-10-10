import Foundation
@testable import Domain

// ロックを省かないのは、@unchecked Sendable でコンパイラによる並行アクセスのチェックを外しているため
final class UpcomingVisitPublisherMock: UpcomingVisitPublishing, @unchecked Sendable {
    private(set) var published: [[UpcomingVisit]] = []

    private let lock = NSLock()

    func publish(_ visits: [UpcomingVisit]) async {
        lock.withLock {
            published.append(visits)
        }
    }
}
