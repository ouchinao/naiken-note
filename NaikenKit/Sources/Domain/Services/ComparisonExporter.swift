import Foundation

public protocol ComparisonExporter: Sendable {
    /// 比較表をPNG画像にする。描画できなければnil
    @MainActor
    func export(_ entries: [ComparisonEntry]) -> Data?
}
