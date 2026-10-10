import Domain
import Foundation

struct StoreChangeObservingStub: StoreChangeObserving {
    var changes: AsyncStream<Void> {
        return AsyncStream { continuation in
            continuation.finish()
        }
    }
}
