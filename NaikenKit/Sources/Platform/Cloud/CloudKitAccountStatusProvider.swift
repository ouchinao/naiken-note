import CloudKit
import Domain
import Foundation

/// `ubiquityIdentityToken` で判定しないのは、iCloud Drive を切っているだけで同期できない扱いになり、CloudKit の状態と一致しないため
public struct CloudKitAccountStatusProvider: CloudAccountStatusProviding {
    private let containerID: String

    public init(containerID: String) {
        self.containerID = containerID
    }

    public func currentStatus() async -> CloudSyncStatus {
        guard let status = try? await CKContainer(identifier: containerID).accountStatus() else {
            return .unavailable
        }
        switch status {
        case .available:
            return .enabled
        case .noAccount:
            return .signedOut
        case .restricted, .couldNotDetermine, .temporarilyUnavailable:
            return .unavailable
        @unknown default:
            return .unavailable
        }
    }
}
