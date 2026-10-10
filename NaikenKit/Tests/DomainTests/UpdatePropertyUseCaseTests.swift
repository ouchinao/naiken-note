import Foundation
import Testing
@testable import Domain

struct UpdatePropertyUseCaseTests {
    private let customerID = UUID()

    @Test("Pro でなければ、お客様のフォルダを付け替えられない", arguments: [Entitlement.free, .unlocked])
    func changingCustomerRequiresPro(entitlement: Entitlement) async {
        let stored = Property.fixture()
        let repository = PropertyRepositoryMock(properties: [stored])
        let useCase = UpdatePropertyUseCase(repository: repository, entitlement: EntitlementProviderStub(current: entitlement))

        await #expect(throws: UpdatePropertyUseCase.Failure.proRequired) {
            try await useCase.execute(reassigned(stored, to: customerID))
        }
        #expect(repository.saved.isEmpty)
    }

    @Test("Pro が切れても、お客様のフォルダを変えなければほかの項目は保存できる")
    func keepsAssignmentWithoutPro() async throws {
        let stored = Property.fixture(customerID: customerID)
        let repository = PropertyRepositoryMock(properties: [stored])
        let useCase = UpdatePropertyUseCase(repository: repository, entitlement: EntitlementProviderStub(current: .unlocked))
        let renamed = Property(
            id: stored.id,
            name: "名前を直した",
            visitedAt: stored.visitedAt,
            customerID: customerID,
            createdAt: stored.createdAt
        )

        try await useCase.execute(renamed)

        #expect(repository.saved == [renamed])
    }

    @Test("Pro ならお客様のフォルダを付け替えられる")
    func proCanChangeCustomer() async throws {
        let stored = Property.fixture()
        let repository = PropertyRepositoryMock(properties: [stored])
        let useCase = UpdatePropertyUseCase(repository: repository, entitlement: EntitlementProviderStub(current: .pro))

        try await useCase.execute(reassigned(stored, to: customerID))

        #expect(repository.saved.first?.customerID == customerID)
    }

    // MARK: - Private

    private func reassigned(_ property: Property, to customerID: UUID) -> Property {
        return Property(
            id: property.id,
            name: property.name,
            visitedAt: property.visitedAt,
            customerID: customerID,
            createdAt: property.createdAt
        )
    }
}
