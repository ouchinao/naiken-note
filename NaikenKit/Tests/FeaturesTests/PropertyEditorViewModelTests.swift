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

    @Test("面積に無限大を入れると保存しない")
    func rejectsInfiniteArea() async {
        let repository = PropertyRepositoryMock()
        let viewModel = makeViewModel(repository: repository)
        viewModel.name = "A棟201"
        viewModel.areaText = "inf"

        await viewModel.save()

        #expect(repository.saved.isEmpty && viewModel.notice != nil)
    }

    @Test("無料版で上限まで登録していると、新しい物件の保存で limitReached の通知を出す")
    func showsLimitNoticeAtLimit() async {
        let viewModel = makeViewModel(repository: PropertyRepositoryMock(count: Limits.freePropertyCount))
        viewModel.name = "D棟101"

        await viewModel.save()

        #expect(viewModel.notice == .limitReached(limit: Limits.freePropertyCount))
    }

    @Test("無料版で上限まで登録していても、登録済みの物件は編集して保存できる")
    func editsExistingPropertyAtLimit() async {
        let property = Property(
            id: UUID(),
            name: "A棟201",
            rent: 80_000,
            visitedAt: Date(timeIntervalSince1970: 1_800_000_000),
            createdAt: Date(timeIntervalSince1970: 1_799_000_000)
        )
        let repository = PropertyRepositoryMock(count: Limits.freePropertyCount, properties: [property])
        let viewModel = makeViewModel(repository: repository, propertyID: property.id)
        await viewModel.load()
        viewModel.rentText = "82,000"

        await viewModel.save()

        let saved = repository.saved.first
        #expect(viewModel.didSave && saved?.id == property.id && saved?.createdAt == property.createdAt)
        #expect(saved?.rent == 82_000 && saved?.name == "A棟201")
    }

    @Test("面積にとても大きな数が入った物件でも、編集画面を開ける")
    func opensPropertyWithHugeArea() async {
        let property = Property(id: UUID(), name: "A棟201", areaSquareMeters: 1e20, visitedAt: Date(), createdAt: Date())
        let viewModel = makeViewModel(repository: PropertyRepositoryMock(properties: [property]), propertyID: property.id)

        await viewModel.load()

        #expect(viewModel.areaText == "1e+20")
    }

    @Test("Pro のときだけ、お客様のフォルダを選ぶ欄を出す", arguments: [(Entitlement.unlocked, false), (.pro, true)])
    func offersCustomerPickerOnlyForPro(entitlement: Entitlement, expected: Bool) {
        let viewModel = makeViewModel(repository: PropertyRepositoryMock(), entitlement: entitlement)

        #expect(viewModel.canAssignCustomer == expected)
    }

    @Test("Pro が切れても、お客様の紐づけを残したまま物件を編集して保存できる")
    func keepsCustomerAfterProExpires() async {
        let customerID = UUID()
        let property = Property(id: UUID(), name: "A棟201", visitedAt: Date(), customerID: customerID, createdAt: Date())
        let repository = PropertyRepositoryMock(properties: [property])
        let viewModel = makeViewModel(repository: repository, propertyID: property.id, entitlement: .unlocked)
        await viewModel.load()
        viewModel.rentText = "90000"

        await viewModel.save()

        #expect(viewModel.didSave && repository.saved.first?.customerID == customerID)
    }

    @Test("Pro でないのにお客様のフォルダを付け替えると、Pro が要ると知らせて保存しない")
    func reassigningCustomerWithoutProShowsNotice() async {
        let property = Property(id: UUID(), name: "A棟201", visitedAt: Date(), createdAt: Date())
        let repository = PropertyRepositoryMock(properties: [property])
        let viewModel = makeViewModel(repository: repository, propertyID: property.id, entitlement: .unlocked)
        await viewModel.load()
        viewModel.customerID = UUID()

        await viewModel.save()

        #expect(viewModel.notice == .proRequired && repository.saved.isEmpty)
    }

    // MARK: - Private

    private func makeViewModel(
        repository: PropertyRepositoryMock,
        propertyID: UUID? = nil,
        entitlement: Entitlement = .free
    ) -> PropertyEditorViewModel {
        let provider = EntitlementProviderStub(current: entitlement)
        return PropertyEditorViewModel(
            propertyID: propertyID,
            fetchProperty: FetchPropertyUseCase(repository: repository),
            addProperty: AddPropertyUseCase(repository: repository, entitlement: provider),
            updateProperty: UpdatePropertyUseCase(repository: repository, entitlement: provider),
            fetchCustomers: FetchCustomersUseCase(repository: CustomerRepositoryStub()),
            entitlementState: EntitlementStateStub(current: entitlement)
        )
    }
}
