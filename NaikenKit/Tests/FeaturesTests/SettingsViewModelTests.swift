import Domain
import Foundation
import Testing
@testable import Features

@MainActor
struct SettingsViewModelTests {
    @Test("iCloud にサインインしていなければ、その状態を出す")
    func loadsCloudStatus() async {
        let viewModel = makeViewModel(cloudStatus: .signedOut)

        await viewModel.load()

        #expect(viewModel.cloudStatus == .signedOut)
    }

    @Test("無料版なら機能を解除するボタンを出し、解除済みなら出さない", arguments: [(Entitlement.free, true), (.unlocked, false)])
    func showsUnlockButtonOnlyForFreeUser(entitlement: Entitlement, expected: Bool) {
        let viewModel = makeViewModel(state: EntitlementStateStub(current: entitlement))

        #expect(viewModel.showsUnlockButton == expected)
    }

    @Test("復元したら購入状態を読み直して知らせる")
    func restoreRefreshesEntitlement() async {
        let state = EntitlementStateStub(current: .free, refreshed: .unlocked)
        let viewModel = makeViewModel(state: state)

        await viewModel.restore()

        #expect(state.refreshCount == 1 && viewModel.notice == .restored && !viewModel.isRestoring)
    }

    // MARK: - Private

    private func makeViewModel(
        cloudStatus: CloudSyncStatus = .enabled,
        state: EntitlementStateStub = EntitlementStateStub(current: .free)
    ) -> SettingsViewModel {
        return SettingsViewModel(
            fetchCloudSyncStatus: FetchCloudSyncStatusUseCase(provider: CloudAccountStatusStub(status: cloudStatus)),
            restorePurchases: RestorePurchasesUseCase(service: PurchaseServiceStub()),
            entitlementState: state
        )
    }
}
