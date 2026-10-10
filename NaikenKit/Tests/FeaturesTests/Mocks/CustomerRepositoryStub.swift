import Domain
import Foundation

/// 顧客のいない顧客Repository
struct CustomerRepositoryStub: CustomerRepository {
    func fetchAll() async throws -> [Customer] {
        return []
    }

    func save(_: Customer) async throws {}

    func delete(id _: UUID) async throws {}
}
