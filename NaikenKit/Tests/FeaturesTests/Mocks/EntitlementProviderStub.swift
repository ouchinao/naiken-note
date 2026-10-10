import Domain
import Foundation

struct EntitlementProviderStub: EntitlementProvider {
    let current: Entitlement

    func currentEntitlement() async -> Entitlement {
        return current
    }
}
