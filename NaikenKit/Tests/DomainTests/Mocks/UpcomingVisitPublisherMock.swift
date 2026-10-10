import Foundation
@testable import Domain

// テストからは逐次呼ぶだけだが、記録はロックで守ってから @unchecked Sendable にする
final class UpcomingVisitPublisherMock: UpcomingVisitPublishing, @unchecked Sendable {
    private(set) var published: [[UpcomingVisit]] = []

    private let lock = NSLock()

    func publish(_ visits: [UpcomingVisit]) async {
        lock.withLock {
            published.append(visits)
        }
    }
}
