import Foundation
import Testing
@testable import Domain

struct FetchPropertiesUseCaseTests {
    private let customerID = UUID()

    @Test("顧客で絞り込むと、その顧客の物件だけを返す")
    func filtersByCustomer() async throws {
        let owned = Property.fixture(name: "顧客の物件", customerID: customerID)
        let other = Property.fixture(name: "未分類の物件")
        let useCase = FetchPropertiesUseCase(repository: PropertyRepositoryMock(properties: [owned, other]))

        let properties = try await useCase.execute(filter: .customer(customerID))

        #expect(properties.map(\.id) == [owned.id])
    }

    @Test("未分類で絞り込むと、顧客のない物件だけを返す")
    func filtersUnassigned() async throws {
        let owned = Property.fixture(name: "顧客の物件", customerID: customerID)
        let other = Property.fixture(name: "未分類の物件")
        let useCase = FetchPropertiesUseCase(repository: PropertyRepositoryMock(properties: [owned, other]))

        let properties = try await useCase.execute(filter: .unassigned)

        #expect(properties.map(\.id) == [other.id])
    }
}
