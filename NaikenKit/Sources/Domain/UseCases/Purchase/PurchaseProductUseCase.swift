import Foundation

public struct PurchaseProductUseCase: Sendable {
    private let service: any PurchaseService

    public init(service: any PurchaseService) {
        self.service = service
    }

    public func execute(productID: String) async throws -> PurchaseOutcome {
        return try await service.purchase(productID)
    }
}
