import Foundation

public protocol PhotoLibraryScanner: Sendable {
    /// 写真ライブラリの読み取り権限を求める。許可されればtrue
    func requestAuthorization() async -> Bool
    /// 撮影日時が期間内の写真を列挙する
    func candidates(takenFrom start: Date, to end: Date) async throws -> [LibraryPhotoCandidate]
    func thumbnailData(for id: String, maxPixelSize: Int) async -> Data?
    func imageData(for id: String) async throws -> Data
}
