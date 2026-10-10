import Domain
import Foundation

struct PhotoLibraryScannerStub: PhotoLibraryScanner {
    var access: PhotoLibraryAccess = .full
    var candidates: [LibraryPhotoCandidate] = []
    var unreadableIDs: Set<String> = []

    func requestAccess() async -> PhotoLibraryAccess {
        return access
    }

    func candidates(takenFrom _: Date, to _: Date) async throws -> [LibraryPhotoCandidate] {
        return candidates
    }

    func thumbnailData(for _: String, maxPixelSize _: Int) async -> Data? {
        return nil
    }

    func imageData(for id: String) async throws -> Data {
        if unreadableIDs.contains(id) {
            throw TestFailure.stubbed
        }
        return Data(id.utf8)
    }
}
