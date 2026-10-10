import CoreData
import Domain
import Foundation

/// 端末内の保存と、CloudKitから届いた変更(`NSPersistentStoreRemoteChange`)をまとめて流す
public final class StoreChangeObserver: StoreChangeObserving {
    private static let localChangeNotification = Notification.Name("NaikenNoteStoreDidChangeLocally")

    public init() {}

    public var changes: AsyncStream<Void> {
        return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let names: [Notification.Name] = [.NSPersistentStoreRemoteChange, Self.localChangeNotification]
            // 監視トークン(NSObjectProtocol)は Sendable ではないが、onTermination で一度だけ removeObserver に渡すだけなので競合しない
            nonisolated(unsafe) let tokens = names.map { name in
                return NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { _ in
                    continuation.yield()
                }
            }
            continuation.onTermination = { _ in
                for token in tokens {
                    NotificationCenter.default.removeObserver(token)
                }
            }
        }
    }

    /// Repository が保存したあとに呼ぶ
    static func postLocalChange() {
        NotificationCenter.default.post(name: localChangeNotification, object: nil)
    }
}
