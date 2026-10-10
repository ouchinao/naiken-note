import Foundation
import Testing
@testable import Domain

struct FetchPropertiesUseCaseTests {
    private let customerID = UUID()

    @Test("一覧は内見日時の新しい順に並べる")
    func sortsByNewestVisit() async throws {
        let older = Property.fixture(name: "古い", visitedAt: Date(timeIntervalSince1970: 1_700_000_000))
        let newer = Property.fixture(name: "新しい", visitedAt: Date(timeIntervalSince1970: 1_800_000_000))
        let useCase = FetchPropertiesUseCase(repository: PropertyRepositoryMock(properties: [older, newer]))

        let properties = try await useCase.execute()

        #expect(properties.map(\.name) == ["新しい", "古い"])
    }

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
