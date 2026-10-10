import Domain
import Foundation

/// ViewModel に `EntitlementStore` を直接持たせないのは、購入や復元の後の振る舞いを StoreKit なしでテストするため
@MainActor
public protocol EntitlementState: AnyObject {
    var current: Entitlement { get }
    func refresh() async
}
