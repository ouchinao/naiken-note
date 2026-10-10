import Domain
import Foundation
import SwiftData
import Testing
@testable import Data

struct SwiftDataPhotoRepositoryTests {
    private let container: ModelContainer
    private let property = Property(id: UUID(), name: "写真の物件", visitedAt: Date(), createdAt: Date())

    init() throws {
        container = try ModelContainerFactory.make(inMemory: true)
    }

    @Test("保存した写真を、部屋タグ・キャプション・撮影日時・並び順もそのまま読み出せる")
    func roundTripsPhotoFields() async throws {
        let repository = SwiftDataPhotoRepository(modelContainer: container)
        try await SwiftDataPropertyRepository(modelContainer: container).save(property)
        let photo = Photo(
            id: UUID(),
            roomTag: .kitchen,
            caption: "コンロは2口",
            takenAt: Date(timeIntervalSince1970: 1_800_000_000),
            sortOrder: 3
        )
        try await repository.save(photo, imageData: Data([1]), thumbnailData: Data([1]), propertyID: property.id)

        let photos = try await repository.photos(propertyID: property.id)

        #expect(photos == [photo])
    }

    @Test("画像とサムネイルを別々に取り出せる")
    func loadsImageAndThumbnail() async throws {
        let repository = SwiftDataPhotoRepository(modelContainer: container)
        try await SwiftDataPropertyRepository(modelContainer: container).save(property)
        let photo = Photo(id: UUID(), roomTag: .bathroom, takenAt: Date())
        try await repository.save(photo, imageData: Data([10]), thumbnailData: Data([20]), propertyID: property.id)

        let image = try await repository.imageData(id: photo.id)
        let thumbnail = try await repository.thumbnailData(id: photo.id)

        #expect(image == Data([10]) && thumbnail == Data([20]))
    }

    @Test("部屋タグの変更を保存できる")
    func updatesRoomTag() async throws {
        let repository = SwiftDataPhotoRepository(modelContainer: container)
        try await SwiftDataPropertyRepository(modelContainer: container).save(property)
        var photo = Photo(id: UUID(), roomTag: .other, takenAt: Date())
        try await repository.save(photo, imageData: Data(), thumbnailData: Data(), propertyID: property.id)
        photo.roomTag = .balcony

        try await repository.update(photo)

        let photos = try await repository.photos(propertyID: property.id)
        #expect(photos.first?.roomTag == .balcony)
    }

    @Test("存在しない物件には写真を保存できない")
    func failsForMissingProperty() async {
        let repository = SwiftDataPhotoRepository(modelContainer: container)
        let photo = Photo(id: UUID(), roomTag: .other, takenAt: Date())

        await #expect(throws: RepositoryError.self) {
            try await repository.save(photo, imageData: Data(), thumbnailData: Data(), propertyID: UUID())
        }
    }
}
