import Foundation

public protocol ImageProcessor: Sendable {
    /// 長辺を `maxPixelSize` 以下に縮小したJPEGを返す
    func downsized(_ data: Data, maxPixelSize: Int) async throws -> Data
    /// 長辺を `maxPixelSize` 以下にしたサムネイルのJPEGを返す
    func thumbnail(_ data: Data, maxPixelSize: Int) async throws -> Data
    /// EXIFの撮影日時。取れなければnil
    func captureDate(of data: Data) -> Date?
}
