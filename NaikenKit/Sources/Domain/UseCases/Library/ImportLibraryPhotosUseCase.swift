import Foundation

public struct ImportLibraryPhotosUseCase: Sendable {
    private let scanner: any PhotoLibraryScanner
    private let addPhoto: AddPhotoUseCase

    public init(scanner: any PhotoLibraryScanner, addPhoto: AddPhotoUseCase) {
        self.scanner = scanner
        self.addPhoto = addPhoto
    }

    public func execute(candidateIDs: [String], propertyID: UUID) async throws -> Int {
        var importedCount = 0
        for candidateID in candidateIDs {
            let data = try await scanner.imageData(for: candidateID)
            _ = try await addPhoto.execute(propertyID: propertyID, original: data, roomTag: .other)
            importedCount += 1
        }
        return importedCount
    }
}
