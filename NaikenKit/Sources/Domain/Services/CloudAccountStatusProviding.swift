import Foundation

public protocol CloudAccountStatusProviding: Sendable {
    func currentStatus() -> CloudSyncStatus
}
