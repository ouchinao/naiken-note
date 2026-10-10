import Foundation

public struct LoadLibraryThumbnailUseCase: Sendable {
    private let scanner: any PhotoLibraryScanner

    public init(scanner: any PhotoLibraryScanner) {
        self.scanner = scanner
    }

    public func execute(candidateID: String) async -> Data? {
        return await scanner.thumbnailData(for: candidateID, maxPixelSize: ImageSpec.thumbnailMaxPixelSize)
    }
}
