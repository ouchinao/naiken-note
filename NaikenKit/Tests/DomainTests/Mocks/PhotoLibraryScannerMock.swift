import Foundation
@testable import Domain

// テストからは逐次呼ぶだけだが、記録はロックで守ってから @unchecked Sendable にする
final class PhotoLibraryScannerMock: PhotoLibraryScanner, @unchecked Sendable {
    private(set) var requestedStarts: [Date] = []
    private(set) var requestedEnds: [Date] = []
    private(set) var loadedIDs: [String] = []

    private let lock = NSLock()
    private let isAuthorized: Bool
    private let stubbedCandidates: [LibraryPhotoCandidate]

    init(isAuthorized: Bool = true, candidates: [LibraryPhotoCandidate] = []) {
        self.isAuthorized = isAuthorized
        stubbedCandidates = candidates
    }

    func requestAuthorization() async -> Bool {
        return isAuthorized
    }

    func candidates(takenFrom start: Date, to end: Date) async throws -> [LibraryPhotoCandidate] {
        lock.withLock {
            requestedStarts.append(start)
            requestedEnds.append(end)
        }
        return stubbedCandidates
    }

    func thumbnailData(for id: String, maxPixelSize: Int) async -> Data? {
        return nil
    }

    func imageData(for id: String) async throws -> Data {
        lock.withLock {
            loadedIDs.append(id)
        }
        return Data(id.utf8)
    }
}
