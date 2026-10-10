import Foundation
import Testing
@testable import Domain

struct ImportLibraryPhotosUseCaseTests {
    @Test("選んだ写真を選んだ順に読み込み、物件の写真として保存する")
    func importsSelectedPhotosIntoProperty() async {
        let scanner = PhotoLibraryScannerMock()
        let photoRepository = PhotoRepositoryMock()
        let propertyID = UUID()
        let useCase = makeUseCase(scanner: scanner, photoRepository: photoRepository)

        let result = await useCase.execute(candidateIDs: ["a1", "b2"], propertyID: propertyID)

        #expect(scanner.loadedIDs == ["a1", "b2"] && result.importedIDs == ["a1", "b2"])
        #expect(photoRepository.saved.map(\.propertyID) == [propertyID, propertyID])
    }

    @Test("読み込めない写真があっても残りは取り込み、読めなかった写真を返す")
    func continuesAfterUnreadablePhoto() async {
        let scanner = PhotoLibraryScannerMock(unreadableIDs: ["b2"])
        let photoRepository = PhotoRepositoryMock()
        let useCase = makeUseCase(scanner: scanner, photoRepository: photoRepository)

        let result = await useCase.execute(candidateIDs: ["a1", "b2", "c3"], propertyID: UUID())

        #expect(result.importedIDs == ["a1", "c3"] && result.failedIDs == ["b2"])
        #expect(photoRepository.saved.count == 2)
    }

    // MARK: - Private

    private func makeUseCase(scanner: PhotoLibraryScannerMock, photoRepository: PhotoRepositoryMock) -> ImportLibraryPhotosUseCase {
        return ImportLibraryPhotosUseCase(
            scanner: scanner,
            addPhoto: AddPhotoUseCase(repository: photoRepository, processor: ImageProcessorMock())
        )
    }
}
