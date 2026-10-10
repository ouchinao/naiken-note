import Foundation

public struct FetchCustomersUseCase: Sendable {
    private let repository: any CustomerRepository

    public init(repository: any CustomerRepository) {
        self.repository = repository
    }

    /// 名前順に返す
    public func execute() async throws -> [Customer] {
        return try await repository.fetchAll()
    }
}
