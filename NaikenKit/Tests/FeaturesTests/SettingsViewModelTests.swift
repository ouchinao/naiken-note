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

    @Test("Pro でなければ機能を解除するボタンを出す", arguments: [(Entitlement.free, true), (.unlocked, true), (.pro, false)])
    func showsUnlockButtonUntilPro(entitlement: Entitlement, expected: Bool) {
        let viewModel = makeViewModel(state: EntitlementStateStub(current: entitlement))

        #expect(viewModel.showsUnlockButton == expected)
    }

    @Test("Pro のときだけ顧客フォルダの管理を出す", arguments: [(Entitlement.unlocked, false), (.pro, true)])
    func showsCustomerFoldersOnlyForPro(entitlement: Entitlement, expected: Bool) {
        let viewModel = makeViewModel(state: EntitlementStateStub(current: entitlement))

        #expect(viewModel.showsCustomerFolders == expected)
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
