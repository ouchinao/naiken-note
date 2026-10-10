import Foundation

public struct KeepUpcomingVisitsUpdatedUseCase: Sendable {
    private let refresh: RefreshUpcomingVisitsUseCase
    private let storeChanges: any StoreChangeObserving

    public init(refresh: RefreshUpcomingVisitsUseCase, storeChanges: any StoreChangeObserving) {
        self.refresh = refresh
        self.storeChanges = storeChanges
    }

    public func execute() async {
        await refreshIgnoringFailure()
        for await _ in storeChanges.changes {
            await refreshIgnoringFailure()
        }
    }

    // MARK: - Private

    /// 失敗を画面に知らせないのは、ウィジェットは補助の表示で、次にストアが変わったときにまた書き直すため
    private func refreshIgnoringFailure() async {
        try? await refresh.execute()
    }
}
