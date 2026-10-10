import Domain
import SwiftUI
import UIKit

/// 比較表をPNG画像にする。SwiftUIのViewを描くので、Platform層ではなくFeatures層に置く
public struct ImageRendererComparisonExporter: ComparisonExporter {
    /// Retina相当の解像度で書き出す
    private static let scale: CGFloat = 3

    public init() {}

    @MainActor
    public func export(_ entries: [ComparisonEntry]) -> Data? {
        let content = ComparisonTableView(entries: entries, showsBranding: true)
            .environment(\.colorScheme, .light)
        let renderer = ImageRenderer(content: content)
        renderer.scale = Self.scale
        return renderer.uiImage?.pngData()
    }
}
