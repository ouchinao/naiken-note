import Foundation
@testable import Domain

// ほかのモックと違ってロックを持たないのは、export が MainActor からしか呼ばれないため
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
