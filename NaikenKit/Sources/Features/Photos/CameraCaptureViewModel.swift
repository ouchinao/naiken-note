import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class CameraCaptureViewModel {
    enum Notice {
        case failed(message: String)
    }

    // MARK: - State

    private(set) var savedCount = 0
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
    private let addPhoto: AddPhotoUseCase

    public init(propertyID: UUID, addPhoto: AddPhotoUseCase) {
        self.propertyID = propertyID
        self.addPhoto = addPhoto
    }

    // MARK: - Actions

    /// 撮るたびに呼ぶ。物件詳細から開いたカメラなので、写真はその物件に自動で紐づく
    func save(_ image: Data) async {
        do {
            _ = try await addPhoto.execute(propertyID: propertyID, original: image, roomTag: .other)
            savedCount += 1
        } catch {
            notice = .failed(message: error.localizedDescription)
        }
    }
}
