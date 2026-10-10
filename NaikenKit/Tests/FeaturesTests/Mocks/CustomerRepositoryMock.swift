import Domain
import Foundation

// ロックを省かないのは、@unchecked Sendable でコンパイラによる並行アクセスのチェックを外しているため
final class CustomerRepositoryMock: CustomerRepository, @unchecked Sendable {
    private(set) var saved: [Customer] = []

    private let lock = NSLock()
    private let failure: (any Error)?

    init(failure: (any Error)? = nil) {
        self.failure = failure
    }

    func fetchAll() async throws -> [Customer] {
        return lock.withLock {
            return saved
        }
    }

    func save(_ customer: Customer) async throws {
        lock.withLock {
            saved.append(customer)
        }
    }

    func delete(id _: UUID) async throws {
        if let failure {
            throw failure
        }
    }
}
