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
    private(set) var thumbnails: [UUID: Data] = [:]
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    /// 比較表に並べる物件。選んだ順に並ぶ
    private(set) var selectedIDs: [UUID] = []
    var isSelecting = false
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

    var canCompare: Bool {
        return (Limits.comparisonMinimumCount...Limits.comparisonMaximumCount).contains(selectedIDs.count)
    }

    // MARK: - Init

    private let fetchProperties: FetchPropertiesUseCase
    private let addProperty: AddPropertyUseCase
    private let loadPhotoImage: LoadPhotoImageUseCase
    private let storeChanges: any StoreChangeObserving

    public init(
        fetchProperties: FetchPropertiesUseCase,
        addProperty: AddPropertyUseCase,
        loadPhotoImage: LoadPhotoImageUseCase,
        storeChanges: any StoreChangeObserving
    ) {
        self.fetchProperties = fetchProperties
        self.addProperty = addProperty
        self.loadPhotoImage = loadPhotoImage
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
            properties = try await fetchProperties.execute()
            await loadThumbnails()
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

    /// 物件を追加できるかを確かめる。上限に達していれば通知を出してfalseを返す
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
