import Domain
import Foundation
import Testing
@testable import Features

@MainActor
struct EntitlementStoreTests {
    @Test("unlock と Pro の両方が有効なら pro になる")
    func proWinsOverUnlock() {
        let store = EntitlementStore(purchaseService: PurchaseServiceStub())

        store.apply([ProductID.unlock, ProductID.proMonthly])

        #expect(store.current == .pro)
    }

    @Test("Pro が切れても unlock は残る")
    func unlockRemainsAfterProExpires() {
        let store = EntitlementStore(purchaseService: PurchaseServiceStub())
        store.apply([ProductID.unlock, ProductID.proMonthly])

        store.apply([ProductID.unlock])

        #expect(store.current == .unlocked)
    }

    @Test("起動直後でも、購入状態を読み終えてから上限や書き出しの判定に使う")
    func currentEntitlementWaitsForInitialLoad() async {
        let store = EntitlementStore(purchaseService: PurchaseServiceStub(entitlements: [ProductID.unlock]))

        let entitlement = await store.currentEntitlement()

        #expect(entitlement == .unlocked)
    }

    @Test("アプリ内で購入したあと読み直すと、新しい購入状態になる")
    func refreshPicksUpNewPurchase() async {
        let service = PurchaseServiceStub()
        let store = EntitlementStore(purchaseService: service)
        _ = await store.currentEntitlement()
        service.setEntitlements([ProductID.unlock])

        await store.refresh()

        #expect(store.current == .unlocked)
    }
}
