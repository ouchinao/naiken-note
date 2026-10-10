import Domain
import Foundation
import Testing
@testable import Features

@MainActor
struct PropertyListViewModelTests {
    @Test("上限に達していると追加の前に limitReached の通知を出す")
    func prepareToAddShowsLimitNotice() async {
        let viewModel = makeViewModel(repository: PropertyRepositoryMock(count: Limits.freePropertyCount))

        let canAdd = await viewModel.prepareToAdd()

        #expect(!canAdd && viewModel.notice == .limitReached(limit: Limits.freePropertyCount))
    }

    @Test("上限に達していなければ追加できる")
    func prepareToAddAllowsUnderLimit() async {
        let viewModel = makeViewModel(repository: PropertyRepositoryMock(count: Limits.freePropertyCount - 1))

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

    @Test("読み込みに失敗したら failed を知らせ、isLoading を戻す")
    func loadFailureShowsNotice() async {
        let viewModel = makeViewModel(repository: PropertyRepositoryMock(failure: TestFailure.stubbed))

        await viewModel.load()

        #expect(viewModel.notice == .failed(message: TestFailure.stubbed.localizedDescription) && !viewModel.isLoading)
    }

    @Test("物件が1件だけなら比較を始められない")
    func cannotStartComparingWithOneProperty() async {
        let property = Property(id: UUID(), name: "A棟201", visitedAt: Date(), createdAt: Date())
        let viewModel = makeViewModel(repository: PropertyRepositoryMock(properties: [property]))

        await viewModel.load()

        #expect(!viewModel.canStartSelecting)
    }

    @Test("比較は2〜4件を選んだときだけできる")
    func comparisonNeedsTwoToFour() {
        let viewModel = makeViewModel(repository: PropertyRepositoryMock())
        let properties = makeProperties(count: 2)
        viewModel.startSelecting()

        viewModel.toggleSelection(of: properties[0])
        let canCompareWithOne = viewModel.canCompare
        viewModel.toggleSelection(of: properties[1])

        #expect(!canCompareWithOne && viewModel.canCompare)
    }

    @Test("選んだ物件をもう一度選ぶと選択を外す")
    func togglingAgainDeselects() {
        let viewModel = makeViewModel(repository: PropertyRepositoryMock())
        let property = makeProperties(count: 1)[0]
        viewModel.toggleSelection(of: property)

        viewModel.toggleSelection(of: property)

        #expect(viewModel.selectedIDs.isEmpty)
    }

    @Test("比較に選べるのは4件まで")
    func selectionIsLimitedToFour() {
        let viewModel = makeViewModel(repository: PropertyRepositoryMock())
        let properties = makeProperties(count: Limits.comparisonMaximumCount + 1)

        for property in properties {
            viewModel.toggleSelection(of: property)
        }

        #expect(viewModel.selectedIDs == properties.prefix(Limits.comparisonMaximumCount).map(\.id))
    }

    @Test("選ぶのをやめると選択を消す")
    func finishSelectingClearsSelection() {
        let viewModel = makeViewModel(repository: PropertyRepositoryMock())
        viewModel.startSelecting()
        viewModel.toggleSelection(of: makeProperties(count: 1)[0])

        viewModel.finishSelecting()

        #expect(!viewModel.isSelecting && viewModel.selectedIDs.isEmpty)
    }

    // MARK: - Private

    private func makeViewModel(repository: PropertyRepositoryMock) -> PropertyListViewModel {
        return PropertyListViewModel(
            fetchProperties: FetchPropertiesUseCase(repository: repository),
            addProperty: AddPropertyUseCase(repository: repository, entitlement: EntitlementProviderStub(current: .free)),
            fetchCustomers: FetchCustomersUseCase(repository: CustomerRepositoryStub()),
            loadPhotoImage: LoadPhotoImageUseCase(repository: PhotoRepositoryStub()),
            storeChanges: StoreChangeObservingStub()
        )
    }

    private func makeProperties(count: Int) -> [Property] {
        return (1...count).map { number in
            return Property(id: UUID(), name: "物件\(number)", visitedAt: Date(), createdAt: Date())
        }
    }
}
