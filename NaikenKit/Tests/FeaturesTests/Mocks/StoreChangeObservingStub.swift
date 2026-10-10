import Domain
import Foundation

/// 変更を一度も流さずに終わる
struct StoreChangeObservingStub: StoreChangeObserving {
    var changes: AsyncStream<Void> {
        return AsyncStream { continuation in
            continuation.finish()
        }
    }
}
