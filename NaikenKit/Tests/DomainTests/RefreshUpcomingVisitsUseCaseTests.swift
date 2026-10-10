import Foundation
import Testing
@testable import Domain

struct RefreshUpcomingVisitsUseCaseTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    @Test("これからの内見だけを近い順に最大3件渡す")
    func publishesUpcomingVisitsInOrder() async throws {
        let past = Property.fixture(name: "過去", visitedAt: now.addingTimeInterval(-3_600))
        let third = Property.fixture(name: "3番目", visitedAt: now.addingTimeInterval(3 * 86_400))
        let first = Property.fixture(name: "1番目", visitedAt: now.addingTimeInterval(3_600))
        let fourth = Property.fixture(name: "4番目", visitedAt: now.addingTimeInterval(4 * 86_400))
        let second = Property.fixture(name: "2番目", visitedAt: now.addingTimeInterval(86_400))
        let publisher = UpcomingVisitPublisherMock()
        let useCase = RefreshUpcomingVisitsUseCase(
            repository: PropertyRepositoryMock(properties: [past, third, first, fourth, second]),
            publisher: publisher
        )

        try await useCase.execute(now: now)

        #expect(publisher.published.first?.map(\.name) == ["1番目", "2番目", "3番目"])
    }

    @Test("これからの内見がなければ空で渡す")
    func publishesEmptyWhenNoUpcomingVisit() async throws {
        let publisher = UpcomingVisitPublisherMock()
        let useCase = RefreshUpcomingVisitsUseCase(
            repository: PropertyRepositoryMock(properties: [Property.fixture(visitedAt: now.addingTimeInterval(-60))]),
            publisher: publisher
        )

        try await useCase.execute(now: now)

        #expect(publisher.published == [[]])
    }
}
