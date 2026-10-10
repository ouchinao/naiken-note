import Foundation

public struct FetchCloudSyncStatusUseCase: Sendable {
    private let provider: any CloudAccountStatusProviding

    public init(provider: any CloudAccountStatusProviding) {
        self.provider = provider
    }

    public func execute() -> CloudSyncStatus {
        return provider.currentStatus()
    }
}
