import Foundation
import Testing
@testable import Domain

struct BuildComparisonUseCaseTests {
    @Test("比較できる件数の範囲外なら invalidSelection で失敗する", arguments: [0, 1, 5])
    func rejectsInvalidCount(count: Int) async {
        let useCase = BuildComparisonUseCase(
            propertyRepository: PropertyRepositoryMock(),
            photoRepository: PhotoRepositoryMock()
        )
        let ids = (0..<count).map { _ in UUID() }

        await #expect(throws: BuildComparisonUseCase.Failure.invalidSelection(count: count)) {
            try await useCase.execute(propertyIDs: ids)
        }
    }

    @Test("選んだ順に列を並べる")
    func keepsSelectionOrder() async throws {
        let first = Property.fixture(name: "A")
        let second = Property.fixture(name: "B")
        let useCase = BuildComparisonUseCase(
            propertyRepository: PropertyRepositoryMock(properties: [first, second]),
            photoRepository: PhotoRepositoryMock()
        )

        let entries = try await useCase.execute(propertyIDs: [second.id, first.id])

        #expect(entries.map(\.id) == [second.id, first.id])
    }

    @Test("並び順が先頭の写真を代表写真にする")
    func usesFirstPhotoAsRepresentative() async throws {
        let later = Photo.fixture(sortOrder: 1)
        let front = Photo.fixture(sortOrder: 0)
        let image = Data("front".utf8)
        let property = Property.fixture(photos: [later, front])
        let other = Property.fixture()
        let useCase = BuildComparisonUseCase(
            propertyRepository: PropertyRepositoryMock(properties: [property, other]),
            photoRepository: PhotoRepositoryMock(images: [front.id: image])
        )

        let entries = try await useCase.execute(propertyIDs: [property.id, other.id])

        #expect(entries.first?.representativeImage == image)
    }

    @Test("別の端末で削除されて見つからない物件は、列に入れずに飛ばす")
    func skipsMissingProperty() async throws {
        let first = Property.fixture(name: "A")
        let second = Property.fixture(name: "B")
        let useCase = BuildComparisonUseCase(
            propertyRepository: PropertyRepositoryMock(properties: [first, second]),
            photoRepository: PhotoRepositoryMock()
        )

        let entries = try await useCase.execute(propertyIDs: [first.id, UUID(), second.id])

        #expect(entries.map(\.id) == [first.id, second.id])
    }
}
