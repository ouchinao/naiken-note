import Foundation

public protocol PhotoRepository: Sendable {
    func save(_ photo: Photo, imageData: Data, thumbnailData: Data, propertyID: UUID) async throws
    /// タグ・キャプション・並び順を更新する。画像は変えない
    func update(_ photo: Photo) async throws
    func delete(id: UUID) async throws
    /// 並び順の昇順で返す
    func photos(propertyID: UUID) async throws -> [Photo]
    func imageData(id: UUID) async throws -> Data?
    func thumbnailData(id: UUID) async throws -> Data?
}
