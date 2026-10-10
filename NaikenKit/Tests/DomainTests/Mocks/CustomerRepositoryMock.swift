import Foundation
@testable import Domain

// テストからは逐次呼ぶだけだが、記録はロックで守ってから @unchecked Sendable にする
final class CustomerRepositoryMock: CustomerRepository, @unchecked Sendable {
    private(set) var saved: [Customer] = []
    private(set) var deletedIDs: [UUID] = []

    private let lock = NSLock()
    private let customers: [Customer]

    init(customers: [Customer] = []) {
        self.customers = customers
    }

    func fetchAll() async throws -> [Customer] {
        return customers
    }

    func save(_ customer: Customer) async throws {
        lock.withLock {
            saved.append(customer)
        }
    }

    func delete(id: UUID) async throws {
        lock.withLock {
            deletedIDs.append(id)
        }
    }
}
