import Domain
import Foundation

// ロックを省かないのは、@unchecked Sendable でコンパイラによる並行アクセスのチェックを外しているため
final class CheckResultRepositoryMock: CheckResultRepository, @unchecked Sendable {
    private(set) var saved: [CheckResult] = []

    private let lock = NSLock()
    private let failure: (any Error)?

    init(failure: (any Error)? = nil) {
        self.failure = failure
    }

    func save(_ result: CheckResult, propertyID _: UUID) async throws {
        if let failure {
            throw failure
        }
        lock.withLock {
            saved.append(result)
        }
    }
}
