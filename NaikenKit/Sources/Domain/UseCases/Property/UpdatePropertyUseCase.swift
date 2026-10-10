import Foundation

public struct UpdatePropertyUseCase: Sendable {
    public enum Failure: Error, Equatable {
        case proRequired
    }

    private let repository: any PropertyRepository
    private let entitlement: any EntitlementProvider

    public init(repository: any PropertyRepository, entitlement: any EntitlementProvider) {
        self.repository = repository
        self.entitlement = entitlement
    }

    /// 割り当てを変えていないときに Pro を求めないのは、Pro が切れても物件とお客様の紐づけは残し、ほかの項目は編集できるようにするため
    public func execute(_ property: Property) async throws {
        let stored = try await repository.fetch(id: property.id)
        if property.customerID != stored?.customerID {
            let current = await entitlement.currentEntitlement()
            if !current.canUseCustomerFolders {
                throw Failure.proRequired
            }
        }
        try await repository.save(property)
    }
}
