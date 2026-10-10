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
            createdAt: Date(timeIntervalSince1970: 1_799_000_000)
        )

        try await repository.save(property)
        let fetched = try await repository.fetch(id: property.id)

        #expect(fetched == property)
    }

    @Test("一覧は内見日の新しい順に返す")
    func fetchAllSortsByVisitDateDescending() async throws {
        let repository = SwiftDataPropertyRepository(modelContainer: container)
        let older = Property(id: UUID(), name: "古い", visitedAt: Date(timeIntervalSince1970: 1_700_000_000), createdAt: Date())
        let newer = Property(id: UUID(), name: "新しい", visitedAt: Date(timeIntervalSince1970: 1_800_000_000), createdAt: Date())
        try await repository.save(older)
        try await repository.save(newer)

        let properties = try await repository.fetchAll()

        #expect(properties.map(\.name) == ["新しい", "古い"])
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
