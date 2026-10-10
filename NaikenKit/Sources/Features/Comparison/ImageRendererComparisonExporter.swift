import Domain
import SwiftUI
import UIKit

/// Platform ではなくここに置くのは、SwiftUI の View を描くため
public struct ImageRendererComparisonExporter: ComparisonExporter {
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
