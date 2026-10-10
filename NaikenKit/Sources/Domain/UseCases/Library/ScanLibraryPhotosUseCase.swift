import Foundation

public struct ScanLibraryPhotosUseCase: Sendable {
    public enum Failure: Error, Equatable {
        case notAuthorized
    }

    private let scanner: any PhotoLibraryScanner

    public init(scanner: any PhotoLibraryScanner) {
        self.scanner = scanner
    }

    public func execute(around visitAt: Date) async throws -> [LibraryPhotoCandidate] {
        let isAuthorized = await scanner.requestAuthorization()
        if !isAuthorized {
            throw Failure.notAuthorized
        }
        let start = visitAt.addingTimeInterval(-LibraryScanRule.timeWindow)
        let end = visitAt.addingTimeInterval(LibraryScanRule.timeWindow)
        let candidates = try await scanner.candidates(takenFrom: start, to: end)
        return LibraryScanRule.filter(candidates, around: visitAt)
    }
}
