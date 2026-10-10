import Foundation

public struct LoadProductsUseCase: Sendable {
    private let service: any PurchaseService

    public init(service: any PurchaseService) {
        self.service = service
    }

    /// 販売中の商品を `ProductID.onSale` の順に返す
    public func execute() async throws -> [PurchasableProduct] {
        let products = try await service.products()
        return ProductID.onSale.compactMap { productID in
            return products.first { $0.id == productID }
        }
    }
}
