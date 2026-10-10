import Foundation

public protocol CustomerRepository: Sendable {
    func fetchAll() async throws -> [Customer]
    func save(_ customer: Customer) async throws
    func delete(id: UUID) async throws
}
