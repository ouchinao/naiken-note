import Foundation
@testable import Domain

// export は MainActor からしか呼ばれないので、記録の競合は起きない
final class ComparisonExporterMock: ComparisonExporter, @unchecked Sendable {
    private(set) var exportedEntries: [[ComparisonEntry]] = []

    private let result: Data?

    init(result: Data?) {
        self.result = result
    }

    @MainActor
    func export(_ entries: [ComparisonEntry]) -> Data? {
        exportedEntries.append(entries)
        return result
    }
}
