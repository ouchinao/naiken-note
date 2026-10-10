import Foundation

public protocol StoreChangeObserving: Sendable {
    /// 保存やiCloudからの同期でストアが変わるたびに値を流す
    var changes: AsyncStream<Void> { get }
}
