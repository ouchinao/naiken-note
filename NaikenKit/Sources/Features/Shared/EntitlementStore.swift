import Domain
import Foundation
import Observation

/// 購入の結果を Paywall で判断しないのは、復元や別の端末での購入、承認待ちだった購入でも状態を1か所で揃えるため
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

    /// `Transaction.updates` を待たずに読み直すのは、アプリ内で完了した購入は updates に流れないため
    func refresh() async {
        apply(await purchaseService.currentEntitlements())
    }

    func apply(_ ids: Set<String>) {
        current = Entitlement(activeProductIDs: ids)
    }
}
