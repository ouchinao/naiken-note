import Foundation
import Testing
@testable import Domain

struct FetchCustomersUseCaseTests {
    @Test("お客様は名前の順に並べる")
    func sortsByName() async throws {
        let customers = ["たなか", "あいかわ", "さとう"].map { name in
            return Customer(id: UUID(), name: name, createdAt: Date())
        }
        let useCase = FetchCustomersUseCase(repository: CustomerRepositoryMock(customers: customers))

        let names = try await useCase.execute().map(\.name)

        #expect(names == ["あいかわ", "さとう", "たなか"])
    }
}
