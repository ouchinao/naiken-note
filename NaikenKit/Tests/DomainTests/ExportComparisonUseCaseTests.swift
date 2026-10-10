import Foundation
import Testing
@testable import Domain

struct ExportComparisonUseCaseTests {
    @Test("無料版では locked で失敗する")
    func freeUserIsLocked() async {
        let useCase = ExportComparisonUseCase(
            entitlement: EntitlementProviderStub(current: .free),
            exporter: ComparisonExporterMock(result: Data([0x89]))
        )

        await #expect(throws: ExportComparisonUseCase.Failure.locked) {
            try await useCase.execute([])
        }
    }

    @Test("無料版では画像を描画しない")
    func freeUserDoesNotRender() async {
        let exporter = ComparisonExporterMock(result: Data([0x89]))
        let useCase = ExportComparisonUseCase(
            entitlement: EntitlementProviderStub(current: .free),
            exporter: exporter
        )

        _ = try? await useCase.execute([])

        #expect(exporter.exportedEntries.isEmpty)
    }

    @Test("解錠済みなら比較表の画像データを返す", arguments: [Entitlement.unlocked, .pro])
    func unlockedUserGetsImage(entitlement: Entitlement) async throws {
        let png = Data([0x89, 0x50, 0x4E, 0x47])
        let useCase = ExportComparisonUseCase(
            entitlement: EntitlementProviderStub(current: entitlement),
            exporter: ComparisonExporterMock(result: png)
        )

        let data = try await useCase.execute([])

        #expect(data == png)
    }

    @Test("描画に失敗すると renderingFailed で失敗する")
    func renderingFailure() async {
        let useCase = ExportComparisonUseCase(
            entitlement: EntitlementProviderStub(current: .unlocked),
            exporter: ComparisonExporterMock(result: nil)
        )

        await #expect(throws: ExportComparisonUseCase.Failure.renderingFailed) {
            try await useCase.execute([])
        }
    }
}
