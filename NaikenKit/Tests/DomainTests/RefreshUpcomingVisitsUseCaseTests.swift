import Foundation
import Testing
@testable import Domain

struct RefreshUpcomingVisitsUseCaseTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    @Test("これからの内見だけを近い順に渡す")
    func publishesUpcomingVisitsInOrder() async throws {
        let past = Property.fixture(name: "過去", visitedAt: now.addingTimeInterval(-3_600))
        let third = Property.fixture(name: "3番目", visitedAt: now.addingTimeInterval(3 * 86_400))
        let first = Property.fixture(name: "1番目", visitedAt: now.addingTimeInterval(3_600))
        let second = Property.fixture(name: "2番目", visitedAt: now.addingTimeInterval(86_400))
        let publisher = UpcomingVisitPublisherMock()
        let useCase = RefreshUpcomingVisitsUseCase(
            repository: PropertyRepositoryMock(properties: [past, third, first, second]),
            publisher: publisher
        )

        try await useCase.execute(now: now)

        #expect(publisher.published.first?.map(\.name) == ["1番目", "2番目", "3番目"])
    }

    @Test("ちょうどいまの内見は、これからの予定に入れない")
    func excludesVisitAtNow() async throws {
        let publisher = UpcomingVisitPublisherMock()
        let useCase = RefreshUpcomingVisitsUseCase(
            repository: PropertyRepositoryMock(properties: [Property.fixture(visitedAt: now)]),
            publisher: publisher
        )

        try await useCase.execute(now: now)

        #expect(publisher.published == [[]])
    }

    @Test("ウィジェットが次の予定へ切り替えられるよう、近い順に20件まで渡す")
    func publishesUpToTwentyVisits() async throws {
        let properties = (1...21).map { day in
            return Property.fixture(name: "\(day)日後", visitedAt: now.addingTimeInterval(Double(day) * 86_400))
        }
        let publisher = UpcomingVisitPublisherMock()
        let useCase = RefreshUpcomingVisitsUseCase(repository: PropertyRepositoryMock(properties: properties), publisher: publisher)

        try await useCase.execute(now: now)

        #expect(publisher.published.first?.count == 20 && publisher.published.first?.last?.name == "20日後")
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
