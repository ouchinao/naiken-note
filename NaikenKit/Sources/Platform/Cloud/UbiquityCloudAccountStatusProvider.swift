import Domain
import Foundation

public struct UbiquityCloudAccountStatusProvider: CloudAccountStatusProviding {
    public init() {}

    public func currentStatus() -> CloudSyncStatus {
        if FileManager.default.ubiquityIdentityToken == nil {
            return .signedOut
        }
        return .enabled
    }
}
