import Foundation

public struct RestorePurchasesUseCase: Sendable {
    private let service: any PurchaseService

    public init(service: any PurchaseService) {
        self.service = service
    }

    public func execute() async throws {
        try await service.restore()
    }
}
