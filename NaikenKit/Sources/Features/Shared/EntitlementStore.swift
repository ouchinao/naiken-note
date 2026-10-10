import Domain
import Foundation
import Observation

/// 購入状態を保持する。Paywallなどの画面はこれを描くだけで、購入処理の結果を自分で判断しない。
/// `EntitlementProvider` に適合するので、UseCaseにそのまま注入できる
@MainActor
@Observable
public final class EntitlementStore: EntitlementProvider {
    public private(set) var current: Entitlement = .free

    private let purchaseService: any PurchaseService

    public init(purchaseService: any PurchaseService) {
        self.purchaseService = purchaseService
        Task { [weak self, purchaseService] in
            let initial = await purchaseService.currentEntitlements()
            self?.apply(initial)
            for await ids in purchaseService.updates {
                self?.apply(ids)
            }
        }
    }

    /// 購入や復元の直後に呼ぶ。`Transaction.updates` はアプリ内で完了した購入を流さないため
    public func refresh() async {
        apply(await purchaseService.currentEntitlements())
    }

    func apply(_ ids: Set<String>) {
        current = Entitlement(activeProductIDs: ids)
    }
}
