import CoreData
import Domain
import Foundation

/// `NSPersistentStoreRemoteChange` だけを見ないのは、端末内の保存ではこの通知が届かないため
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

    static func postLocalChange() {
        NotificationCenter.default.post(name: localChangeNotification, object: nil)
    }
}
