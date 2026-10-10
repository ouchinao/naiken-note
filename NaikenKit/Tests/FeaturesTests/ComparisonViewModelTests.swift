import Domain
import Foundation
import Testing
@testable import Features

@MainActor
struct ComparisonViewModelTests {
    @Test("無料版で比較表を画像にしようとすると locked の通知を出す")
    func exportShowsLockedNoticeForFreeUser() async {
        let viewModel = makeViewModel(entitlement: .free)

        await viewModel.export()

        #expect(viewModel.notice == .locked && viewModel.exportedImage == nil)
    }

    @Test("解錠済みなら比較表の画像を作る")
    func exportCreatesImageForUnlockedUser() async {
        let viewModel = makeViewModel(entitlement: .unlocked)

        await viewModel.export()

        #expect(viewModel.exportedImage == Data([0x89]))
    }

    // MARK: - Private

    private func makeViewModel(entitlement: Entitlement) -> ComparisonViewModel {
        return ComparisonViewModel(
            propertyIDs: [],
            buildComparison: BuildComparisonUseCase(
                propertyRepository: PropertyRepositoryMock(),
                photoRepository: PhotoRepositoryStub()
            ),
            exportComparison: ExportComparisonUseCase(
                entitlement: EntitlementProviderStub(current: entitlement),
                exporter: ComparisonExporterStub(result: Data([0x89]))
            )
        )
    }
}
