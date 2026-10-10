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

    @Test("チェック結果のメモを保存して読み出せる")
    func roundTripsCheckResultNote() async throws {
        let propertyRepository = SwiftDataPropertyRepository(modelContainer: container)
        let repository = SwiftDataCheckResultRepository(modelContainer: container)
        try await propertyRepository.save(property)
        let result = CheckResult(id: UUID(), itemKey: "noise", rating: .neutral, note: "線路が近い")

        try await repository.save(result, propertyID: property.id)

        let results = try await propertyRepository.fetch(id: property.id)?.checkResults ?? []
        #expect(results == [result])
    }

    @Test("2台の端末から同じ項目の結果が届いていても、次に保存すると1件にまとめる")
    func savingRemovesDuplicatesFromOtherDevices() async throws {
        let propertyRepository = SwiftDataPropertyRepository(modelContainer: container)
        let repository = SwiftDataCheckResultRepository(modelContainer: container)
        try await propertyRepository.save(property)
        try insertCheckResultRecords(itemKey: "noise", count: 2)
        let fetched = try await propertyRepository.fetch(id: property.id)
        let shown = try #require(fetched?.checkResult(forItemKey: "noise"))
        var edited = shown
        edited.rating = .bad

        try await repository.save(edited, propertyID: property.id)

        let context = ModelContext(container)
        let records = try context.fetch(FetchDescriptor<CheckResultRecord>())
        #expect(records.count == 1)
        #expect(records.first?.id == shown.id && records.first?.rating == CheckResult.Rating.bad.rawValue)
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

    @Test("採寸のメモと紐づけた写真を保存して読み出せる")
    func roundTripsMeasurementFields() async throws {
        let propertyRepository = SwiftDataPropertyRepository(modelContainer: container)
        let repository = SwiftDataMeasurementRepository(modelContainer: container)
        try await propertyRepository.save(property)
        let measurement = Measurement(
            id: UUID(),
            label: "カーテンレールの幅",
            valueMillimeters: 1_820,
            note: "レールの内側で測った",
            photoID: UUID(),
            createdAt: Date(timeIntervalSince1970: 1_800_000_000)
        )

        try await repository.save(measurement, propertyID: property.id)

        let measurements = try await propertyRepository.fetch(id: property.id)?.measurements ?? []
        #expect(measurements == [measurement])
    }

    // MARK: - Private

    private func insertCheckResultRecords(itemKey: String, count: Int) throws {
        let context = ModelContext(container)
        guard let propertyRecord = try context.propertyRecord(id: property.id) else {
            return
        }
        for _ in 0..<count {
            let record = CheckResultRecord(id: UUID(), itemKey: itemKey)
            record.rating = CheckResult.Rating.good.rawValue
            context.insert(record)
            record.property = propertyRecord
        }
        try context.save()
    }
}
