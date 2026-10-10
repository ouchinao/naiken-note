import Foundation
import Testing
@testable import Domain

struct ImportLibraryPhotosUseCaseTests {
    @Test("選んだ写真をすべて取り込み、その枚数を返す")
    func importsSelectedPhotos() async throws {
        let scanner = PhotoLibraryScannerMock()
        let photoRepository = PhotoRepositoryMock()
        let useCase = ImportLibraryPhotosUseCase(
            scanner: scanner,
            addPhoto: AddPhotoUseCase(repository: photoRepository, processor: ImageProcessorMock())
        )

        let count = try await useCase.execute(candidateIDs: ["a1", "b2"], propertyID: UUID())

        #expect(count == 2 && photoRepository.saved.count == 2)
    }
}
