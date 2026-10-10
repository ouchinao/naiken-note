import Foundation

public struct AddPhotoUseCase: Sendable {
    private let repository: any PhotoRepository
    private let processor: any ImageProcessor

    public init(repository: any PhotoRepository, processor: any ImageProcessor) {
        self.repository = repository
        self.processor = processor
    }

    public func execute(propertyID: UUID, original: Data, roomTag: Photo.RoomTag) async throws -> Photo {
        async let image = processor.downsized(original, maxPixelSize: ImageSpec.maxPixelSize)
        async let thumbnail = processor.thumbnail(original, maxPixelSize: ImageSpec.thumbnailMaxPixelSize)
        let takenAt = processor.captureDate(of: original) ?? Date()
        let sortOrder = try await nextSortOrder(propertyID: propertyID)
        let photo = Photo(id: UUID(), roomTag: roomTag, caption: "", takenAt: takenAt, sortOrder: sortOrder)
        try await repository.save(photo, imageData: image, thumbnailData: thumbnail, propertyID: propertyID)
        return photo
    }

    // MARK: - Private

    private func nextSortOrder(propertyID: UUID) async throws -> Int {
        let photos = try await repository.photos(propertyID: propertyID)
        guard let last = photos.map(\.sortOrder).max() else {
            return 0
        }
        return last + 1
    }
}
