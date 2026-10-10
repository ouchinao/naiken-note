import Foundation

public protocol ComparisonExporter: Sendable {
    @MainActor
    func export(_ entries: [ComparisonEntry]) -> Data?
}
