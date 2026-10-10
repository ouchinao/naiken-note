import Domain
import Foundation

/// 顧客のいない顧客Repository
struct CustomerRepositoryStub: CustomerRepository {
    func fetchAll() async throws -> [Customer] {
        return []
    }

    func save(_ customer: Customer) async throws {}

    func delete(id: UUID) async throws {}
}
