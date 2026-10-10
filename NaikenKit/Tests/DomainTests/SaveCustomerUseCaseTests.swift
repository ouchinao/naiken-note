import Foundation
import Testing
@testable import Domain

struct SaveCustomerUseCaseTests {
    @Test("Pro でなければ proRequired で失敗する", arguments: [Entitlement.free, .unlocked])
    func requiresPro(entitlement: Entitlement) async {
        let useCase = SaveCustomerUseCase(
            repository: CustomerRepositoryMock(),
            entitlement: EntitlementProviderStub(current: entitlement)
        )

        await #expect(throws: SaveCustomerUseCase.Failure.proRequired) {
            try await useCase.execute(Customer(id: UUID(), name: "山田様", createdAt: Date()))
        }
    }

    @Test("名前が空なら emptyName で失敗する")
    func rejectsEmptyName() async {
        let useCase = SaveCustomerUseCase(
            repository: CustomerRepositoryMock(),
            entitlement: EntitlementProviderStub(current: .pro)
        )

        await #expect(throws: SaveCustomerUseCase.Failure.emptyName) {
            try await useCase.execute(Customer(id: UUID(), name: "", createdAt: Date()))
        }
    }

    @Test("Pro なら顧客を保存する")
    func savesForPro() async throws {
        let repository = CustomerRepositoryMock()
        let useCase = SaveCustomerUseCase(
            repository: repository,
            entitlement: EntitlementProviderStub(current: .pro)
        )
        let customer = Customer(id: UUID(), name: "山田様", createdAt: Date())

        try await useCase.execute(customer)

        #expect(repository.saved == [customer])
    }
}
