import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class SettingsViewModel {
    enum Notice: Equatable {
        case restored
        case failed(message: String)
    }

    // MARK: - State

    private(set) var cloudStatus: CloudSyncStatus?
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

    var entitlement: Entitlement {
        return entitlementState.current
    }

    var showsUnlockButton: Bool {
        return entitlementState.current == .free
    }

    // MARK: - Init

    private let fetchCloudSyncStatus: FetchCloudSyncStatusUseCase
    private let restorePurchases: RestorePurchasesUseCase
    private let entitlementState: any EntitlementState

    public init(
        fetchCloudSyncStatus: FetchCloudSyncStatusUseCase,
        restorePurchases: RestorePurchasesUseCase,
        entitlementState: any EntitlementState
    ) {
        self.fetchCloudSyncStatus = fetchCloudSyncStatus
        self.restorePurchases = restorePurchases
        self.entitlementState = entitlementState
    }

    // MARK: - Actions

    func load() async {
        cloudStatus = await fetchCloudSyncStatus.execute()
    }

    func restore() async {
        guard !isRestoring else {
            return
        }
        isRestoring = true
        defer {
            isRestoring = false
        }
        do {
            try await restorePurchases.execute()
            await entitlementState.refresh()
            notice = .restored
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }
}
