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

    @Test("保存したお客様を、メモや登録日時もそのまま読み出せる")
    func roundTripsCustomerFields() async throws {
        let repository = SwiftDataCustomerRepository(modelContainer: container)
        let customer = Customer(id: UUID(), name: "山田様", memo: "4月から転勤", createdAt: Date(timeIntervalSince1970: 1_800_000_000))

        try await repository.save(customer)

        let customers = try await repository.fetchAll()
        #expect(customers == [customer])
    }
}
