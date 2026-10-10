import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class SettingsViewModel {
    enum Notice {
        case restored
        case failed(message: String)
    }

    // MARK: - State

    private(set) var cloudStatus: CloudSyncStatus = .enabled
    private(set) var isRestoring = false
    private(set) var notice: Notice?

    var isNoticePresented: Bool {
        get {
            return notice != nil
        }
        set {
            if !newValue {
                notice = nil
            }
        }
    }

    // MARK: - Init

    private let fetchCloudSyncStatus: FetchCloudSyncStatusUseCase
    private let restorePurchases: RestorePurchasesUseCase
    private let entitlementStore: EntitlementStore

    public init(
        fetchCloudSyncStatus: FetchCloudSyncStatusUseCase,
        restorePurchases: RestorePurchasesUseCase,
        entitlementStore: EntitlementStore
    ) {
        self.fetchCloudSyncStatus = fetchCloudSyncStatus
        self.restorePurchases = restorePurchases
        self.entitlementStore = entitlementStore
    }

    // MARK: - Actions

    func load() {
        cloudStatus = fetchCloudSyncStatus.execute()
    }

    func restore() async {
        isRestoring = true
        defer {
            isRestoring = false
        }
        do {
            try await restorePurchases.execute()
            await entitlementStore.refresh()
            notice = .restored
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }
}
