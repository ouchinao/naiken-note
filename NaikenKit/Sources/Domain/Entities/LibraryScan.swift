import Foundation

public struct LibraryScan: Sendable {
    public let candidates: [LibraryPhotoCandidate]
    public let isAccessLimited: Bool
}
