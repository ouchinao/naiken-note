import Foundation

public struct DeleteCustomerUseCase: Sendable {
    private let repository: any CustomerRepository

    public init(repository: any CustomerRepository) {
        self.repository = repository
    }

    /// 顧客を削除する。属していた物件は残り、未分類になる
    public func execute(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
