import Domain
import Foundation
import Testing
@testable import Features

@MainActor
struct PropertyListViewModelTests {
    @Test("上限に達していると追加の前に limitReached の通知を出す")
    func prepareToAddShowsLimitNotice() async {
        let viewModel = makeViewModel(repository: PropertyRepositoryMock(count: 3))

        let canAdd = await viewModel.prepareToAdd()

        #expect(!canAdd && viewModel.notice == .limitReached(limit: 3))
    }

    @Test("上限に達していなければ追加できる")
    func prepareToAddAllowsUnderLimit() async {
        let viewModel = makeViewModel(repository: PropertyRepositoryMock(count: 2))

        let canAdd = await viewModel.prepareToAdd()

        #expect(canAdd && viewModel.notice == nil)
    }

    @Test("読み込みが終わると isLoading を戻し、物件を並べる")
    func loadShowsProperties() async {
        let property = Property(id: UUID(), name: "A棟201", visitedAt: Date(), createdAt: Date())
        let viewModel = makeViewModel(repository: PropertyRepositoryMock(properties: [property]))

        await viewModel.load()

        #expect(!viewModel.isLoading && viewModel.properties.map(\.name) == ["A棟201"])
    }

    @Test("比較に選べるのは4件まで")
    func selectionIsLimitedToFour() {
        let viewModel = makeViewModel(repository: PropertyRepositoryMock())
        let properties = (1...5).map { number in
            return Property(id: UUID(), name: "物件\(number)", visitedAt: Date(), createdAt: Date())
        }

        for property in properties {
            viewModel.toggleSelection(of: property)
        }

        #expect(viewModel.selectedIDs == properties.prefix(4).map(\.id))
    }

    // MARK: - Private

    private func makeViewModel(repository: PropertyRepositoryMock) -> PropertyListViewModel {
        return PropertyListViewModel(
            fetchProperties: FetchPropertiesUseCase(repository: repository),
            addProperty: AddPropertyUseCase(repository: repository, entitlement: EntitlementProviderStub(current: .free)),
            loadPhotoImage: LoadPhotoImageUseCase(repository: PhotoRepositoryStub()),
            storeChanges: StoreChangeObservingStub()
        )
    }
}
