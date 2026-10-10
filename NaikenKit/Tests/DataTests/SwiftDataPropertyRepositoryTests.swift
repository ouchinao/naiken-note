import Domain
import Foundation
import SwiftData
import Testing
@testable import Data

struct SwiftDataPropertyRepositoryTests {
    private let container: ModelContainer

    init() throws {
        container = try ModelContainerFactory.make(inMemory: true)
    }

    @Test("保存した物件をすべての項目そのままで読み出せる")
    func roundTripsAllFields() async throws {
        let repository = SwiftDataPropertyRepository(modelContainer: container)
        let customer = Customer(id: UUID(), name: "山田様", createdAt: Date())
        try await SwiftDataCustomerRepository(modelContainer: container).save(customer)
        let property = Property(
            id: UUID(),
            name: "A棟201",
            rent: 92_000,
            layout: "1LDK",
            areaSquareMeters: 35.2,
            nearestStation: "学芸大学",
            walkMinutes: 6,
            visitedAt: Date(timeIntervalSince1970: 1_800_000_000),
            memo: "角部屋",
            customerID: customer.id,
            createdAt: Date(timeIntervalSince1970: 1_799_000_000)
        )

        try await repository.save(property)
        let fetched = try await repository.fetch(id: property.id)

        #expect(fetched == property)
    }

    @Test("保存した物件はすべて一覧に含める")
    func fetchAllReturnsEverySavedProperty() async throws {
        let repository = SwiftDataPropertyRepository(modelContainer: container)
        let first = Property(id: UUID(), name: "A棟201", visitedAt: Date(), createdAt: Date())
        let second = Property(id: UUID(), name: "B棟101", visitedAt: Date(), createdAt: Date())
        try await repository.save(first)
        try await repository.save(second)

        let ids = try await repository.fetchAll().map(\.id)

        #expect(Set(ids) == [first.id, second.id])
    }

    @Test("指定した日時より後に内見する物件だけを読み出せる")
    func fetchesPropertiesVisitedAfterDate() async throws {
        let repository = SwiftDataPropertyRepository(modelContainer: container)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let past = Property(id: UUID(), name: "済み", visitedAt: now.addingTimeInterval(-60), createdAt: now)
        let upcoming = Property(id: UUID(), name: "これから", visitedAt: now.addingTimeInterval(60), createdAt: now)
        try await repository.save(past)
        try await repository.save(upcoming)

        let properties = try await repository.fetchAll(visitedAfter: now)

        #expect(properties.map(\.name) == ["これから"])
    }

    @Test("同じ物件を保存し直すと上書きし、件数は増えない")
    func savingAgainUpdatesInPlace() async throws {
        let repository = SwiftDataPropertyRepository(modelContainer: container)
        let property = Property(id: UUID(), name: "変更前", visitedAt: Date(), createdAt: Date())
        try await repository.save(property)
        let renamed = Property(id: property.id, name: "変更後", visitedAt: property.visitedAt, createdAt: property.createdAt)

        try await repository.save(renamed)

        let names = try await repository.fetchAll().map(\.name)
        #expect(names == ["変更後"])
    }

    @Test("物件を削除すると写真もまとめて消える")
    func deleteCascadesToPhotos() async throws {
        let repository = SwiftDataPropertyRepository(modelContainer: container)
        let photoRepository = SwiftDataPhotoRepository(modelContainer: container)
        let property = Property(id: UUID(), name: "削除する物件", visitedAt: Date(), createdAt: Date())
        let photo = Photo(id: UUID(), roomTag: .kitchen, takenAt: Date())
        try await repository.save(property)
        try await photoRepository.save(photo, imageData: Data([1]), thumbnailData: Data([2]), propertyID: property.id)

        try await repository.delete(id: property.id)

        let imageData = try await photoRepository.imageData(id: photo.id)
        #expect(imageData == nil)
    }
}
