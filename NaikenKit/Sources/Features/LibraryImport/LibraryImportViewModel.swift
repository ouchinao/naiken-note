import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class LibraryImportViewModel {
    enum Phase {
        case loading
        case notAuthorized
        case empty
        case ready
    }

    enum Notice {
        case failed(message: String)
    }

    // MARK: - State

    private(set) var phase: Phase = .loading
    private(set) var candidates: [LibraryPhotoCandidate] = []
    private(set) var thumbnails: [String: Data] = [:]
    private(set) var selectedIDs: Set<String> = []
    private(set) var isImporting = false
    private(set) var didImport = false
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

    private let propertyID: UUID
    private let fetchProperty: FetchPropertyUseCase
    private let scanLibrary: ScanLibraryPhotosUseCase
    private let importLibrary: ImportLibraryPhotosUseCase
    private let loadThumbnail: LoadLibraryThumbnailUseCase

    public init(
        propertyID: UUID,
        fetchProperty: FetchPropertyUseCase,
        scanLibrary: ScanLibraryPhotosUseCase,
        importLibrary: ImportLibraryPhotosUseCase,
        loadThumbnail: LoadLibraryThumbnailUseCase
    ) {
        self.propertyID = propertyID
        self.fetchProperty = fetchProperty
        self.scanLibrary = scanLibrary
        self.importLibrary = importLibrary
        self.loadThumbnail = loadThumbnail
    }

    // MARK: - Actions

    func load() async {
        do {
            guard let property = try await fetchProperty.execute(id: propertyID) else {
                phase = .empty
                return
            }
            candidates = try await scanLibrary.execute(around: property.visitedAt)
            selectedIDs = Set(candidates.map(\.id))
            phase = candidates.isEmpty ? .empty : .ready
            await loadThumbnails()
        } catch ScanLibraryPhotosUseCase.Failure.notAuthorized {
            phase = .notAuthorized
        } catch {
            phase = .empty
            notice = .failed(message: error.localizedDescription)
        }
    }

    func toggle(_ candidate: LibraryPhotoCandidate) {
        if selectedIDs.contains(candidate.id) {
            selectedIDs.remove(candidate.id)
        } else {
            selectedIDs.insert(candidate.id)
        }
    }

    func isSelected(_ candidate: LibraryPhotoCandidate) -> Bool {
        return selectedIDs.contains(candidate.id)
    }

    func importSelected() async {
        isImporting = true
        defer {
            isImporting = false
        }
        let ids = candidates.map(\.id).filter { selectedIDs.contains($0) }
        do {
            _ = try await importLibrary.execute(candidateIDs: ids, propertyID: propertyID)
            didImport = true
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }

    // MARK: - Private

    private func loadThumbnails() async {
        for candidate in candidates {
            if let data = await loadThumbnail.execute(candidateID: candidate.id) {
                thumbnails[candidate.id] = data
            }
        }
    }
}
