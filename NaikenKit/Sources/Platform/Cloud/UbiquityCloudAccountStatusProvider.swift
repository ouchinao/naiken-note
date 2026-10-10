import Domain
import Foundation

/// iCloudにサインインしているかを `FileManager.default.ubiquityIdentityToken` の有無で判定する
public struct UbiquityCloudAccountStatusProvider: CloudAccountStatusProviding {
    public init() {}

    public func currentStatus() -> CloudSyncStatus {
        if FileManager.default.ubiquityIdentityToken == nil {
            return .signedOut
        }
        return .enabled
    }
}
