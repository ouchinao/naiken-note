import Domain
import Foundation
import SwiftData
import Testing
@testable import Data

struct SwiftDataCustomerRepositoryTests {
    private let container: ModelContainer

    init() throws {
        container = try ModelContainerFactory.make(inMemory: true)
    }

    @Test("顧客は名前の順に返す")
    func fetchAllSortsByName() async throws {
        let repository = SwiftDataCustomerRepository(modelContainer: container)
        for name in ["たなか", "あいかわ", "さとう"] {
            try await repository.save(Customer(id: UUID(), name: name, createdAt: Date()))
        }

        let names = try await repository.fetchAll().map(\.name)

        #expect(names == ["あいかわ", "さとう", "たなか"])
    }
}
