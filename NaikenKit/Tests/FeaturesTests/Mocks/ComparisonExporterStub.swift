import Domain
import Foundation

/// 固定のデータを返す
struct ComparisonExporterStub: ComparisonExporter {
    let result: Data?

    @MainActor
    func export(_ entries: [ComparisonEntry]) -> Data? {
        return result
    }
}
