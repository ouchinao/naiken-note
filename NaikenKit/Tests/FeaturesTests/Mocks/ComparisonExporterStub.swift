import Domain
import Foundation

struct ComparisonExporterStub: ComparisonExporter {
    let result: Data?

    @MainActor
    func export(_: [ComparisonEntry]) -> Data? {
        return result
    }
}
