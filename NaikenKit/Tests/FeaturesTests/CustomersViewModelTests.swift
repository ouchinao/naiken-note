import Domain
import Foundation
import Testing
@testable import Features

@MainActor
struct CustomersViewModelTests {
    @Test("名前の前後の空白を除いてお客様を追加する")
    func addsCustomerWithTrimmedName() async {
        let repository = CustomerRepositoryMock()
        let viewModel = makeViewModel(repository: repository)

        await viewModel.add(name: "  山田様 ")

        #expect(repository.saved.map(\.name) == ["山田様"])
    }

    @Test("Pro でなければ追加せず、Pro が要ると知らせる")
    func requiresProToAdd() async {
        let repository = CustomerRepositoryMock()
        let viewModel = makeViewModel(repository: repository, entitlement: .unlocked)

        await viewModel.add(name: "山田様")

        #expect(viewModel.notice == .proRequired && repository.saved.isEmpty)
    }

    @Test("名前が空なら追加せずに知らせる")
    func rejectsEmptyName() async {
        let repository = CustomerRepositoryMock()
        let viewModel = makeViewModel(repository: repository)

        await viewModel.add(name: "   ")

        #expect(viewModel.notice == .emptyName && repository.saved.isEmpty)
    }

    @Test("名前を変えると、前後の空白を除いて同じお客様として保存する")
    func renamesCustomer() async {
        let repository = CustomerRepositoryMock()
        let viewModel = makeViewModel(repository: repository)
        let customer = Customer(id: UUID(), name: "山田様", createdAt: Date())

        await viewModel.rename(customer, to: " 山田一郎様 ")

        #expect(repository.saved.map(\.id) == [customer.id] && repository.saved.map(\.name) == ["山田一郎様"])
    }

    @Test("削除に失敗したら知らせる")
    func reportsDeleteFailure() async {
        let viewModel = makeViewModel(repository: CustomerRepositoryMock(failure: TestFailure.stubbed))

        await viewModel.delete([Customer(id: UUID(), name: "山田様", createdAt: Date())])

        #expect(viewModel.notice == .failed(message: TestFailure.stubbed.localizedDescription))
    }

    // MARK: - Private

    private func makeViewModel(repository: CustomerRepositoryMock, entitlement: Entitlement = .pro) -> CustomersViewModel {
        return CustomersViewModel(
            fetchCustomers: FetchCustomersUseCase(repository: repository),
            saveCustomer: SaveCustomerUseCase(repository: repository, entitlement: EntitlementProviderStub(current: entitlement)),
            deleteCustomer: DeleteCustomerUseCase(repository: repository),
            storeChanges: StoreChangeObservingStub()
        )
    }
}
