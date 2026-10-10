import Domain
import Foundation
@testable import Features

@MainActor
final class EntitlementStateStub: EntitlementState {
    var current: Entitlement
    private(set) var refreshCount = 0

    private let refreshed: Entitlement?

    init(current: Entitlement, refreshed: Entitlement? = nil) {
        self.current = current
        self.refreshed = refreshed
    }

    func refresh() async {
        refreshCount += 1
        if let refreshed {
            current = refreshed
        }
    }
}
