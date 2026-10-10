import Foundation

public protocol PhotoLibraryScanner: Sendable {
    func requestAuthorization() async -> Bool
    func candidates(takenFrom start: Date, to end: Date) async throws -> [LibraryPhotoCandidate]
    func thumbnailData(for id: String, maxPixelSize: Int) async -> Data?
    func imageData(for id: String) async throws -> Data
}
