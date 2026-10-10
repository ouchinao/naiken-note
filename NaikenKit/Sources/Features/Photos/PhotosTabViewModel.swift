import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class PhotosTabViewModel {
    enum Notice: Equatable {
        case unreadable(count: Int)
        case failed(message: String)
    }

    // MARK: - State

    private(set) var thumbnails: [UUID: Data] = [:]
    private(set) var isImporting = false
    private(set) var selectedTag: Photo.RoomTag?
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

    private let addPhoto: AddPhotoUseCase
    private let updatePhoto: UpdatePhotoUseCase
    private let deletePhoto: DeletePhotoUseCase
    private let setRepresentativePhoto: SetRepresentativePhotoUseCase
    private let loadPhotoImage: LoadPhotoImageUseCase

    public init(
        addPhoto: AddPhotoUseCase,
        updatePhoto: UpdatePhotoUseCase,
        deletePhoto: DeletePhotoUseCase,
        setRepresentativePhoto: SetRepresentativePhotoUseCase,
        loadPhotoImage: LoadPhotoImageUseCase
    ) {
        self.addPhoto = addPhoto
        self.updatePhoto = updatePhoto
        self.deletePhoto = deletePhoto
        self.setRepresentativePhoto = setRepresentativePhoto
        self.loadPhotoImage = loadPhotoImage
    }

    // MARK: - Actions

    func photos(of property: Property) -> [Photo] {
        guard let selectedTag else {
            return property.photos
        }
        return property.photos.filter { $0.roomTag == selectedTag }
    }

    func loadThumbnails(for photos: [Photo]) async {
        for photo in photos where thumbnails[photo.id] == nil {
            if let data = try? await loadPhotoImage.execute(photoID: photo.id, variant: .thumbnail) {
                thumbnails[photo.id] = data
            }
        }
    }

    func selectTag(_ tag: Photo.RoomTag?) {
        selectedTag = tag
    }

    /// 写真を読み込み終えてから取り込み中にしないのは、iCloud にしかない写真のダウンロードを待つ間も操作中だと分かるようにするため
    func beginImport() {
        isImporting = true
    }

    func importPhotos(_ images: [Data], unreadableCount: Int, into propertyID: UUID) async {
        isImporting = true
        defer {
            isImporting = false
        }
        for image in images {
            do {
                _ = try await addPhoto.execute(propertyID: propertyID, original: image, roomTag: selectedTag ?? .other)
            } catch {
                notice = .failed(message: error.localizedDescription)
                return
            }
        }
        if unreadableCount > 0 {
            notice = .unreadable(count: unreadableCount)
        }
    }

    func changeTag(of photo: Photo, to tag: Photo.RoomTag) async {
        var updated = photo
        updated.roomTag = tag
        await save(updated)
    }

    func changeCaption(of photo: Photo, to caption: String) async {
        var updated = photo
        updated.caption = caption
        await save(updated)
    }

    func makeRepresentative(_ photo: Photo, in propertyID: UUID) async {
        do {
            try await setRepresentativePhoto.execute(photoID: photo.id, propertyID: propertyID)
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }

    func delete(_ photo: Photo) async {
        do {
            try await deletePhoto.execute(id: photo.id)
            thumbnails[photo.id] = nil
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }

    // MARK: - Private

    private func save(_ photo: Photo) async {
        do {
            try await updatePhoto.execute(photo)
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }
}
