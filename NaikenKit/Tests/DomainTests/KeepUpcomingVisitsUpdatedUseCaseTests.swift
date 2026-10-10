import Foundation
import Testing
@testable import Domain

struct KeepUpcomingVisitsUpdatedUseCaseTests {
    @Test("始めたときと、ストアが変わるたびにウィジェットの予定を書き直す")
    func republishesOnEveryStoreChange() async {
        let publisher = UpcomingVisitPublisherMock()
        let refresh = RefreshUpcomingVisitsUseCase(repository: PropertyRepositoryMock(), publisher: publisher)
        let useCase = KeepUpcomingVisitsUpdatedUseCase(refresh: refresh, storeChanges: StoreChangeObservingMock(changeCount: 2))

        await useCase.execute()

        #expect(publisher.published.count == 3)
    }
}
