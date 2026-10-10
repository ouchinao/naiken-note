import Domain
import Foundation

struct CloudAccountStatusStub: CloudAccountStatusProviding {
    let status: CloudSyncStatus

    func currentStatus() async -> CloudSyncStatus {
        return status
    }
}
