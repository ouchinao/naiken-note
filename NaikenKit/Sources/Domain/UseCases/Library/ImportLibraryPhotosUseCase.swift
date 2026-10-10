import Foundation

public struct ImportLibraryPhotosUseCase: Sendable {
    private let scanner: any PhotoLibraryScanner
    private let addPhoto: AddPhotoUseCase

    public init(scanner: any PhotoLibraryScanner, addPhoto: AddPhotoUseCase) {
        self.scanner = scanner
        self.addPhoto = addPhoto
    }

    /// 1枚の失敗で残りを止めないのは、圏外で iCloud にしかない写真が混ざっていても、読める写真は取り込み、取り込んだ写真を選び直させないため
    public func execute(candidateIDs: [String], propertyID: UUID) async -> LibraryImportResult {
        var importedIDs: [String] = []
        var failedIDs: [String] = []
        for candidateID in candidateIDs {
            do {
                let data = try await scanner.imageData(for: candidateID)
                _ = try await addPhoto.execute(propertyID: propertyID, original: data, roomTag: .other)
                importedIDs.append(candidateID)
            } catch {
                failedIDs.append(candidateID)
            }
        }
        return LibraryImportResult(importedIDs: importedIDs, failedIDs: failedIDs)
    }
}
