import Domain
import Foundation
import Testing
@testable import Features

@MainActor
struct PhotosTabViewModelTests {
    @Test("部屋タグを選ぶと、そのタグの写真だけを出す")
    func filtersPhotosByTag() {
        let kitchen = Photo(id: UUID(), roomTag: .kitchen, takenAt: Date(), sortOrder: 0)
        let living = Photo(id: UUID(), roomTag: .living, takenAt: Date(), sortOrder: 1)
        let property = Property(id: UUID(), name: "A棟201", visitedAt: Date(), photos: [kitchen, living], createdAt: Date())
        let viewModel = makeViewModel(repository: PhotoRepositoryMock())

        viewModel.selectTag(.kitchen)

        #expect(viewModel.photos(of: property) == [kitchen])
    }

    @Test("取り込んだ写真には、いま選んでいる部屋タグを付ける")
    func importedPhotosGetSelectedTag() async {
        let repository = PhotoRepositoryMock()
        let viewModel = makeViewModel(repository: repository)
        viewModel.selectTag(.bathroom)

        await viewModel.importPhotos([Data([1])], unreadableCount: 0, into: UUID())

        #expect(repository.saved.map(\.roomTag) == [.bathroom])
    }

    @Test("読み込めなかった写真があれば、読み込めた写真を取り込んだうえでその枚数を知らせる")
    func reportsUnreadablePhotos() async {
        let repository = PhotoRepositoryMock()
        let viewModel = makeViewModel(repository: repository)
        viewModel.beginImport()

        await viewModel.importPhotos([Data([1])], unreadableCount: 2, into: UUID())

        #expect(repository.saved.count == 1 && viewModel.notice == .unreadable(count: 2) && !viewModel.isImporting)
    }

    // MARK: - Private

    private func makeViewModel(repository: PhotoRepositoryMock) -> PhotosTabViewModel {
        return PhotosTabViewModel(
            addPhoto: AddPhotoUseCase(repository: repository, processor: ImageProcessorStub()),
            updatePhoto: UpdatePhotoUseCase(repository: repository),
            deletePhoto: DeletePhotoUseCase(repository: repository),
            setRepresentativePhoto: SetRepresentativePhotoUseCase(repository: repository),
            loadPhotoImage: LoadPhotoImageUseCase(repository: repository)
        )
    }
}
