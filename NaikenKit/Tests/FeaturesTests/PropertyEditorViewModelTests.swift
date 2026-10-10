import Domain
import Foundation
import Testing
@testable import Features

@MainActor
struct PropertyEditorViewModelTests {
    @Test("家賃に数字以外を入れると保存しない")
    func rejectsNonNumericRent() async {
        let repository = PropertyRepositoryMock()
        let viewModel = makeViewModel(repository: repository)
        viewModel.name = "A棟201"
        viewModel.rentText = "八万円"

        await viewModel.save()

        #expect(repository.saved.isEmpty && !viewModel.didSave)
    }

    @Test("カンマや全角数字の家賃を数値として保存する", arguments: ["85,000", "８５０００"])
    func acceptsFormattedRent(rentText: String) async {
        let repository = PropertyRepositoryMock()
        let viewModel = makeViewModel(repository: repository)
        viewModel.name = "A棟201"
        viewModel.rentText = rentText

        await viewModel.save()

        #expect(repository.saved.first?.rent == 85_000)
    }

    @Test("無料版で4件目を保存しようとすると limitReached の通知を出す")
    func showsLimitNoticeAtLimit() async {
        let viewModel = makeViewModel(repository: PropertyRepositoryMock(count: 3))
        viewModel.name = "D棟101"

        await viewModel.save()

        #expect(viewModel.notice == .limitReached(limit: 3))
    }

    // MARK: - Private

    private func makeViewModel(repository: PropertyRepositoryMock) -> PropertyEditorViewModel {
        return PropertyEditorViewModel(
            propertyID: nil,
            fetchProperty: FetchPropertyUseCase(repository: repository),
            addProperty: AddPropertyUseCase(repository: repository, entitlement: EntitlementProviderStub(current: .free)),
            updateProperty: UpdatePropertyUseCase(repository: repository)
        )
    }
}
