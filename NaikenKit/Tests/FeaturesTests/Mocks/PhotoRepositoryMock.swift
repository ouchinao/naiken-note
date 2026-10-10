import Domain
import Foundation

// ロックを省かないのは、@unchecked Sendable でコンパイラによる並行アクセスのチェックを外しているため
final class PhotoRepositoryMock: PhotoRepository, @unchecked Sendable {
    private(set) var saved: [Photo] = []

    private let lock = NSLock()

    func save(_ photo: Photo, imageData _: Data, thumbnailData _: Data, propertyID _: UUID) async throws {
        lock.withLock {
            saved.append(photo)
        }
    }

    func update(_: Photo) async throws {}

    func delete(id _: UUID) async throws {}

    func photos(propertyID _: UUID) async throws -> [Photo] {
        return lock.withLock {
            return saved
        }
    }

    func imageData(id _: UUID) async throws -> Data? {
        return nil
    }

    func thumbnailData(id _: UUID) async throws -> Data? {
        return nil
    }
}
