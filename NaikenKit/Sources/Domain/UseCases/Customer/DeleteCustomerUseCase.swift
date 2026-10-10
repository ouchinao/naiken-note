import Foundation

public struct DeleteCustomerUseCase: Sendable {
    private let repository: any CustomerRepository

    public init(repository: any CustomerRepository) {
        self.repository = repository
    }

    public func execute(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
