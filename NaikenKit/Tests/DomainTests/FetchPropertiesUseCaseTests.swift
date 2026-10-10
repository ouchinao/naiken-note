import Foundation
import Testing
@testable import Domain

struct FetchPropertiesUseCaseTests {
    @Test("一覧は内見日時の新しい順に並べる")
    func sortsByNewestVisit() async throws {
        let older = Property.fixture(name: "古い", visitedAt: Date(timeIntervalSince1970: 1_700_000_000))
        let newer = Property.fixture(name: "新しい", visitedAt: Date(timeIntervalSince1970: 1_800_000_000))
        let useCase = FetchPropertiesUseCase(repository: PropertyRepositoryMock(properties: [older, newer]))

        let properties = try await useCase.execute()

        #expect(properties.map(\.name) == ["新しい", "古い"])
    }
}
