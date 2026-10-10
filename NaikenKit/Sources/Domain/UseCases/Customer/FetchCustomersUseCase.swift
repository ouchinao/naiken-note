import Foundation

public struct FetchCustomersUseCase: Sendable {
    private let repository: any CustomerRepository

    public init(repository: any CustomerRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [Customer] {
        return try await repository.fetchAll().sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
