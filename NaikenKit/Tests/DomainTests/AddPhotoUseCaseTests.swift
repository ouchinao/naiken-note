import Foundation
import Testing
@testable import Domain

struct AddPhotoUseCaseTests {
    @Test("保存する画像は長辺2,048pxに縮小する")
    func downsizesTo2048() async throws {
        let processor = ImageProcessorMock()
        let useCase = AddPhotoUseCase(repository: PhotoRepositoryMock(), processor: processor)

        _ = try await useCase.execute(propertyID: UUID(), original: Data(), roomTag: .living)

        #expect(processor.downsizedSizes == [2_048])
    }

    @Test("サムネイルは長辺320pxで作る")
    func makesThumbnailAt320() async throws {
        let processor = ImageProcessorMock()
        let useCase = AddPhotoUseCase(repository: PhotoRepositoryMock(), processor: processor)

        _ = try await useCase.execute(propertyID: UUID(), original: Data(), roomTag: .living)

        #expect(processor.thumbnailSizes == [320])
    }

    @Test("撮影日時はEXIFの値を使う")
    func usesExifDate() async throws {
        let captureDate = Date(timeIntervalSince1970: 1_790_000_000)
        let useCase = AddPhotoUseCase(
            repository: PhotoRepositoryMock(),
            processor: ImageProcessorMock(captureDate: captureDate)
        )

        let photo = try await useCase.execute(propertyID: UUID(), original: Data(), roomTag: .kitchen)

        #expect(photo.takenAt == captureDate)
    }

    @Test("EXIFに撮影日時がなければ取り込んだ時刻にする")
    func fallsBackToNow() async throws {
        let useCase = AddPhotoUseCase(repository: PhotoRepositoryMock(), processor: ImageProcessorMock())
        let before = Date()

        let photo = try await useCase.execute(propertyID: UUID(), original: Data(), roomTag: .kitchen)

        #expect(photo.takenAt >= before && photo.takenAt <= Date())
    }

    @Test("既存の写真の後ろに並べる")
    func appendsAfterExistingPhotos() async throws {
        let repository = PhotoRepositoryMock(photos: [Photo.fixture(sortOrder: 0), Photo.fixture(sortOrder: 3)])
        let useCase = AddPhotoUseCase(repository: repository, processor: ImageProcessorMock())

        let photo = try await useCase.execute(propertyID: UUID(), original: Data(), roomTag: .living)

        #expect(photo.sortOrder == 4)
    }

    @Test("縮小した画像とサムネイルを物件に紐づけて保存する")
    func savesProcessedImagesToProperty() async throws {
        let repository = PhotoRepositoryMock()
        let propertyID = UUID()
        let useCase = AddPhotoUseCase(repository: repository, processor: ImageProcessorMock())

        _ = try await useCase.execute(propertyID: propertyID, original: Data(), roomTag: .living)

        let saved = try #require(repository.saved.first)
        #expect(saved.propertyID == propertyID)
        #expect(saved.imageData == Data("image-2048".utf8))
        #expect(saved.thumbnailData == Data("thumbnail-320".utf8))
    }
}
