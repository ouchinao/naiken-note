import Foundation
import Testing
@testable import Domain

struct LoadProductsUseCaseTests {
    @Test("販売中の買い切りだけを返し、それ以外の商品は除く")
    func returnsProductsOnSale() async throws {
        let products = [
            PurchasableProduct(id: ProductID.proMonthly, displayName: "Pro", displayPrice: "¥980"),
            PurchasableProduct(id: "com.example.unknown", displayName: "?", displayPrice: "¥0"),
            PurchasableProduct(id: ProductID.unlock, displayName: "解除", displayPrice: "¥480"),
        ]
        let useCase = LoadProductsUseCase(service: PurchaseServiceMock(products: products))

        let result = try await useCase.execute()

        #expect(result.map(\.id) == [ProductID.unlock])
    }
}
