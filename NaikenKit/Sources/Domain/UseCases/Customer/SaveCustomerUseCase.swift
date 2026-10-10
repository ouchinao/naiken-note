import Foundation

/// 顧客別フォルダを作成・変更する。Proでなければ `Failure.proRequired` を投げる
public struct SaveCustomerUseCase: Sendable {
    public enum Failure: Error, Equatable {
        case proRequired
        case emptyName
    }

    private let repository: any CustomerRepository
    private let entitlement: any EntitlementProvider

    public init(repository: any CustomerRepository, entitlement: any EntitlementProvider) {
        self.repository = repository
        self.entitlement = entitlement
    }

    public func execute(_ customer: Customer) async throws {
        let current = await entitlement.current
        if !current.canUseCustomerFolders {
            throw Failure.proRequired
        }
        if customer.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw Failure.emptyName
        }
        try await repository.save(customer)
    }
}
