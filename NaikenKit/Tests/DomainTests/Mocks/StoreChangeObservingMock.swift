import Foundation
@testable import Domain

struct StoreChangeObservingMock: StoreChangeObserving {
    let changeCount: Int

    var changes: AsyncStream<Void> {
        return AsyncStream { continuation in
            for _ in 0..<changeCount {
                continuation.yield()
            }
            continuation.finish()
        }
    }
}
