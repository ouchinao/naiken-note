import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class PropertyDetailViewModel {
    enum Notice {
        case failed(message: String)
    }

    // MARK: - State

    private(set) var property: Property?
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var isDeleted = false
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

    let propertyID: UUID
    private let fetchProperty: FetchPropertyUseCase
    private let deleteProperty: DeletePropertyUseCase
    private let storeChanges: any StoreChangeObserving

    public init(
        propertyID: UUID,
        fetchProperty: FetchPropertyUseCase,
        deleteProperty: DeletePropertyUseCase,
        storeChanges: any StoreChangeObserving
    ) {
        self.propertyID = propertyID
        self.fetchProperty = fetchProperty
        self.deleteProperty = deleteProperty
        self.storeChanges = storeChanges
    }

    // MARK: - Actions

    func load() async {
        isLoading = true
        defer {
            isLoading = false
            hasLoaded = true
        }
        do {
            property = try await fetchProperty.execute(id: propertyID)
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }

    /// 保存やiCloudからの同期でストアが変わるたびに読み込み直す。画面を離れると止まる
    func observeChanges() async {
        for await _ in storeChanges.changes {
            try? await Task.sleep(for: StoreChangeDebounce.interval)
            await load()
        }
    }

    func delete() async {
        do {
            try await deleteProperty.execute(id: propertyID)
            isDeleted = true
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }
}
