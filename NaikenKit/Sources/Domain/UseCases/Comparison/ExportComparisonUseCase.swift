import Foundation

public struct ExportComparisonUseCase: Sendable {
    public enum Failure: Error, Equatable {
        case locked
        case renderingFailed
    }

    private let entitlement: any EntitlementProvider
    private let exporter: any ComparisonExporter

    public init(entitlement: any EntitlementProvider, exporter: any ComparisonExporter) {
        self.entitlement = entitlement
        self.exporter = exporter
    }

    public func execute(_ entries: [ComparisonEntry]) async throws -> Data {
        let current = await entitlement.current
        if !current.canExportComparison {
            throw Failure.locked
        }
        guard let data = await exporter.export(entries) else {
            throw Failure.renderingFailed
        }
        return data
    }
}
