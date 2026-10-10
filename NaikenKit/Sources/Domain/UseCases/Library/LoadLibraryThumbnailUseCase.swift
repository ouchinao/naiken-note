import Foundation

/// 写真ライブラリの候補を一覧に出すためのサムネイルを取り出す
public struct LoadLibraryThumbnailUseCase: Sendable {
    private let scanner: any PhotoLibraryScanner

    public init(scanner: any PhotoLibraryScanner) {
        self.scanner = scanner
    }

    public func execute(candidateID: String) async -> Data? {
        return await scanner.thumbnailData(for: candidateID, maxPixelSize: ImageSpec.thumbnailMaxPixelSize)
    }
}
