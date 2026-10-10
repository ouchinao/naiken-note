import Foundation
@testable import Domain

struct EntitlementProviderStub: EntitlementProvider {
    let current: Entitlement
}
