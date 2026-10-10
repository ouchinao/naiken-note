import Domain
import Foundation
import SwiftData
import Testing
@testable import Data

struct SwiftDataChildRepositoryTests {
    private let container: ModelContainer
    private let property = Property(id: UUID(), name: "子レコードの物件", visitedAt: Date(), createdAt: Date())

    init() throws {
        container = try ModelContainerFactory.make(inMemory: true)
    }

    @Test("同じ項目のチェック結果は上書きし、1件だけ残す")
    func checkResultIsUpsertedByItemKey() async throws {
        let propertyRepository = SwiftDataPropertyRepository(modelContainer: container)
        let repository = SwiftDataCheckResultRepository(modelContainer: container)
        try await propertyRepository.save(property)
        try await repository.save(CheckResult(id: UUID(), itemKey: "noise", rating: .bad), propertyID: property.id)

        try await repository.save(CheckResult(id: UUID(), itemKey: "noise", rating: .good), propertyID: property.id)

        let results = try await propertyRepository.fetch(id: property.id)?.checkResults ?? []
        #expect(results.map(\.rating) == [.good])
    }

    @Test("採寸メモを保存し直すと上書きする")
    func measurementIsUpdatedInPlace() async throws {
        let propertyRepository = SwiftDataPropertyRepository(modelContainer: container)
        let repository = SwiftDataMeasurementRepository(modelContainer: container)
        try await propertyRepository.save(property)
        let measurement = Measurement(id: UUID(), label: "窓の幅", valueMillimeters: 1_690, createdAt: Date())
        try await repository.save(measurement, propertyID: property.id)
        let remeasured = Measurement(
            id: measurement.id,
            label: measurement.label,
            valueMillimeters: 1_700,
            createdAt: measurement.createdAt
        )

        try await repository.save(remeasured, propertyID: property.id)

        let measurements = try await propertyRepository.fetch(id: property.id)?.measurements ?? []
        #expect(measurements.map(\.valueMillimeters) == [1_700])
    }

    @Test("顧客を削除しても物件は残り、未分類になる")
    func deletingCustomerKeepsProperties() async throws {
        let propertyRepository = SwiftDataPropertyRepository(modelContainer: container)
        let customerRepository = SwiftDataCustomerRepository(modelContainer: container)
        let customer = Customer(id: UUID(), name: "山田様", createdAt: Date())
        try await customerRepository.save(customer)
        var assigned = property
        assigned.customerID = customer.id
        try await propertyRepository.save(assigned)

        try await customerRepository.delete(id: customer.id)

        let fetched = try await propertyRepository.fetch(id: property.id)
        #expect(fetched != nil && fetched?.customerID == nil)
    }
}
