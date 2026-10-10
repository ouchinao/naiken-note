import Foundation
@testable import Domain

struct EntitlementProviderStub: EntitlementProvider {
    let current: Entitlement

    func currentEntitlement() async -> Entitlement {
        return current
    }
}
