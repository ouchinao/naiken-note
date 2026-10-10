import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class PhotoViewerViewModel {
    // MARK: - State

    private(set) var imageData: Data?
    private(set) var hasLoaded = false

    // MARK: - Init

    private let photoID: UUID
    private let loadPhotoImage: LoadPhotoImageUseCase

    public init(photoID: UUID, loadPhotoImage: LoadPhotoImageUseCase) {
        self.photoID = photoID
        self.loadPhotoImage = loadPhotoImage
    }

    // MARK: - Actions

    func load() async {
        imageData = try? await loadPhotoImage.execute(photoID: photoID, variant: .full)
        hasLoaded = true
    }
}
