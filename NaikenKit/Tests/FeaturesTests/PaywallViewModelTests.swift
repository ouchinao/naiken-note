import Domain
import Foundation
import Testing
@testable import Features

@MainActor
struct PaywallViewModelTests {
    private let unlock = PurchasableProduct(id: ProductID.unlock, displayName: "機能の解除", displayPrice: "¥480")
    private let pro = PurchasableProduct(id: ProductID.proMonthly, displayName: "Pro", displayPrice: "¥980")

    @Test("購入できたら購入状態を読み直して画面を閉じる")
    func purchaseRefreshesEntitlement() async {
        let state = EntitlementStateStub(current: .free, refreshed: .unlocked)
        let viewModel = makeViewModel(service: PurchaseServiceStub(outcome: .purchased), state: state)

        await viewModel.purchase(unlock)

        #expect(state.refreshCount == 1 && viewModel.didPurchase && !viewModel.isPurchasing)
    }

    @Test("承認待ちなら pending を知らせ、画面は閉じない")
    func pendingPurchaseShowsNotice() async {
        let viewModel = makeViewModel(service: PurchaseServiceStub(outcome: .pending))

        await viewModel.purchase(unlock)

        #expect(viewModel.notice == .pending && !viewModel.didPurchase)
    }

    @Test("購入をやめたら何も知らせず、画面も閉じない")
    func cancelledPurchaseDoesNothing() async {
        let state = EntitlementStateStub(current: .free)
        let viewModel = makeViewModel(service: PurchaseServiceStub(outcome: .cancelled), state: state)

        await viewModel.purchase(unlock)

        #expect(viewModel.notice == nil && !viewModel.didPurchase && state.refreshCount == 0)
    }

    @Test("購入に失敗したら failed を知らせ、購入中の表示を戻す")
    func failedPurchaseShowsNotice() async {
        let viewModel = makeViewModel(service: PurchaseServiceStub(failure: TestFailure.stubbed))

        await viewModel.purchase(unlock)

        #expect(viewModel.notice == .failed(message: TestFailure.stubbed.localizedDescription) && !viewModel.isPurchasing)
    }

    @Test("解除済みなら買い切りは買えないが、Pro は買える")
    func unlockedUserCanStillBuyPro() {
        let viewModel = makeViewModel(state: EntitlementStateStub(current: .unlocked))

        #expect(!viewModel.canPurchase(unlock) && viewModel.canPurchase(pro))
    }

    @Test("Pro なら買い切りもサブスクも買えない")
    func proUserCannotBuyAgain() {
        let viewModel = makeViewModel(state: EntitlementStateStub(current: .pro))

        #expect(!viewModel.canPurchase(unlock) && !viewModel.canPurchase(pro))
    }

    @Test("復元したら購入状態を読み直して知らせる")
    func restoreRefreshesEntitlement() async {
        let state = EntitlementStateStub(current: .free, refreshed: .unlocked)
        let viewModel = makeViewModel(state: state)

        await viewModel.restore()

        #expect(state.refreshCount == 1 && viewModel.notice == .restored && !viewModel.isRestoring)
    }

    @Test("商品を読み込めなかったら、知らせたうえで再読み込みできるようにする")
    func offersRetryWhenProductsFailToLoad() async {
        let viewModel = makeViewModel(service: PurchaseServiceStub(failure: TestFailure.stubbed))

        await viewModel.load()

        #expect(viewModel.canRetryLoading && viewModel.notice != nil)
    }

    @Test("商品を読み込めたら再読み込みは出さない")
    func hidesRetryAfterLoadingProducts() async {
        let viewModel = makeViewModel(service: PurchaseServiceStub(products: [unlock]))

        await viewModel.load()

        #expect(!viewModel.canRetryLoading && viewModel.products == [unlock])
    }

    // MARK: - Private

    private func makeViewModel(
        service: PurchaseServiceStub = PurchaseServiceStub(),
        state: EntitlementStateStub = EntitlementStateStub(current: .free)
    ) -> PaywallViewModel {
        return PaywallViewModel(
            loadProducts: LoadProductsUseCase(service: service),
            purchaseProduct: PurchaseProductUseCase(service: service),
            restorePurchases: RestorePurchasesUseCase(service: service),
            entitlementState: state
        )
    }
}
