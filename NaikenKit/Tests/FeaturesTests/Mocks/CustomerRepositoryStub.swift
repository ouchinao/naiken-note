import Domain
import Foundation

struct CustomerRepositoryStub: CustomerRepository {
    func fetchAll() async throws -> [Customer] {
        return []
    }

    func save(_: Customer) async throws {}

    func delete(id _: UUID) async throws {}
}
