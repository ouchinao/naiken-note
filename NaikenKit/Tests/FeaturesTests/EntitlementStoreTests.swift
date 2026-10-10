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

    @Test("購入済みの状態を読み込み直せる")
    func refreshLoadsCurrentEntitlements() async {
        let store = EntitlementStore(purchaseService: PurchaseServiceStub(entitlements: [ProductID.unlock]))

        await store.refresh()

        #expect(store.current == .unlocked)
    }
}
