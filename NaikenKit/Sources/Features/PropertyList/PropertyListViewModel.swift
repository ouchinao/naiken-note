import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class PropertyListViewModel {
    enum Notice: Equatable {
        case limitReached(limit: Int)
        case failed(message: String)
    }

    // MARK: - State

    private(set) var properties: [Property] = []
    private(set) var customers: [Customer] = []
    private(set) var thumbnails: [UUID: Data] = [:]
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var selectedIDs: [UUID] = []
    private(set) var isSelecting = false
    private(set) var filter: CustomerFilter = .all
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

    var showsFolderMenu: Bool {
        return entitlementState.current.canUseCustomerFolders
    }

    var canStartSelecting: Bool {
        return properties.count >= Limits.comparisonMinimumCount
    }

    var canCompare: Bool {
        return (Limits.comparisonMinimumCount...Limits.comparisonMaximumCount).contains(selectedIDs.count)
    }

    // MARK: - Init

    private let fetchProperties: FetchPropertiesUseCase
    private let addProperty: AddPropertyUseCase
    private let fetchCustomers: FetchCustomersUseCase
    private let loadPhotoImage: LoadPhotoImageUseCase
    private let storeChanges: any StoreChangeObserving
    private let entitlementState: any EntitlementState

    public init(
        fetchProperties: FetchPropertiesUseCase,
        addProperty: AddPropertyUseCase,
        fetchCustomers: FetchCustomersUseCase,
        loadPhotoImage: LoadPhotoImageUseCase,
        storeChanges: any StoreChangeObserving,
        entitlementState: any EntitlementState
    ) {
        self.fetchProperties = fetchProperties
        self.addProperty = addProperty
        self.fetchCustomers = fetchCustomers
        self.loadPhotoImage = loadPhotoImage
        self.storeChanges = storeChanges
        self.entitlementState = entitlementState
    }

    // MARK: - Actions

    /// サムネイルを読み終えるまで読み込み中の表示を続けないのは、写真の多い物件があっても一覧をすぐに出すため
    func load() async {
        isLoading = true
        // 絞り込みを残さないのは、Pro が切れるとフォルダのメニューが消えて、ユーザーが解除できなくなるため
        if !showsFolderMenu {
            filter = .all
        }
        do {
            properties = try await fetchProperties.execute(filter: filter)
            customers = try await fetchCustomers.execute()
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
        isLoading = false
        hasLoaded = true
        await loadThumbnails()
    }

    func observeChanges() async {
        for await _ in storeChanges.changes {
            try? await Task.sleep(for: StoreChangeDebounce.interval)
            await load()
        }
    }

    func prepareToAdd() async -> Bool {
        do {
            try await addProperty.checkLimit()
            return true
        } catch AddPropertyUseCase.Failure.limitReached(let limit) {
            notice = .limitReached(limit: limit)
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
        return false
    }

    func select(_ filter: CustomerFilter) async {
        self.filter = filter
        await load()
    }

    func startSelecting() {
        isSelecting = true
    }

    func toggleSelection(of property: Property) {
        if let index = selectedIDs.firstIndex(of: property.id) {
            selectedIDs.remove(at: index)
        } else if selectedIDs.count < Limits.comparisonMaximumCount {
            selectedIDs.append(property.id)
        }
    }

    func isSelected(_ property: Property) -> Bool {
        return selectedIDs.contains(property.id)
    }

    func finishSelecting() {
        isSelecting = false
        selectedIDs = []
    }

    func customerName(of property: Property) -> String? {
        return customers.first { $0.id == property.customerID }?.name
    }

    // MARK: - Private

    private func loadThumbnails() async {
        var loaded: [UUID: Data] = [:]
        for property in properties {
            if let photo = property.representativePhoto,
               let data = try? await loadPhotoImage.execute(photoID: photo.id, variant: .thumbnail) {
                loaded[property.id] = data
            }
        }
        thumbnails = loaded
    }
}
