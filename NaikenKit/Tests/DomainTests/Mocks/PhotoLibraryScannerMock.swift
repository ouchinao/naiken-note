import Foundation
@testable import Domain

// ロックを省かないのは、@unchecked Sendable でコンパイラによる並行アクセスのチェックを外しているため
final class PhotoLibraryScannerMock: PhotoLibraryScanner, @unchecked Sendable {
    private(set) var requestedStarts: [Date] = []
    private(set) var requestedEnds: [Date] = []
    private(set) var loadedIDs: [String] = []

    private let lock = NSLock()
    private let access: PhotoLibraryAccess
    private let stubbedCandidates: [LibraryPhotoCandidate]
    private let unreadableIDs: Set<String>

    init(access: PhotoLibraryAccess = .full, candidates: [LibraryPhotoCandidate] = [], unreadableIDs: Set<String> = []) {
        self.access = access
        stubbedCandidates = candidates
        self.unreadableIDs = unreadableIDs
    }

    func requestAccess() async -> PhotoLibraryAccess {
        return access
    }

    func candidates(takenFrom start: Date, to end: Date) async throws -> [LibraryPhotoCandidate] {
        lock.withLock {
            requestedStarts.append(start)
            requestedEnds.append(end)
        }
        return stubbedCandidates
    }

    func thumbnailData(for _: String, maxPixelSize _: Int) async -> Data? {
        return nil
    }

    func imageData(for id: String) async throws -> Data {
        lock.withLock {
            loadedIDs.append(id)
        }
        if unreadableIDs.contains(id) {
            throw TestFailure.stubbed
        }
        return Data(id.utf8)
    }
}
