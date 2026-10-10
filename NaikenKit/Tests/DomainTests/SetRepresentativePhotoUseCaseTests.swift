import Foundation
import Testing
@testable import Domain

struct SetRepresentativePhotoUseCaseTests {
    @Test("選んだ写真を先頭にして、残りを元の順で後ろに並べる")
    func movesChosenPhotoToFront() async throws {
        let first = Photo.fixture(sortOrder: 0)
        let second = Photo.fixture(sortOrder: 1)
        let third = Photo.fixture(sortOrder: 2)
        let repository = PhotoRepositoryMock(photos: [first, second, third])
        let useCase = SetRepresentativePhotoUseCase(repository: repository)

        try await useCase.execute(photoID: third.id, propertyID: UUID())

        #expect(repository.updated.map(\.id) == [third.id, first.id, second.id])
    }

    @Test("すでに先頭の写真を選んでも何も更新しない")
    func doesNothingForFrontPhoto() async throws {
        let first = Photo.fixture(sortOrder: 0)
        let repository = PhotoRepositoryMock(photos: [first, Photo.fixture(sortOrder: 1)])
        let useCase = SetRepresentativePhotoUseCase(repository: repository)

        try await useCase.execute(photoID: first.id, propertyID: UUID())

        #expect(repository.updated.isEmpty)
    }
}
