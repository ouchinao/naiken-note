import Foundation

public protocol StoreChangeObserving: Sendable {
    var changes: AsyncStream<Void> { get }
}
