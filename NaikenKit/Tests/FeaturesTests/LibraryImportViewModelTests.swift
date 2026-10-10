import Domain
import Foundation
import Testing
@testable import Features

@MainActor
struct LibraryImportViewModelTests {
    private let property = Property(
        id: UUID(),
        name: "A棟201",
        visitedAt: Date(timeIntervalSince1970: 1_800_000_000),
        createdAt: Date(timeIntervalSince1970: 1_799_000_000)
    )

    @Test("見つかった写真は、はじめからすべて選んだ状態にする")
    func selectsEveryCandidateFirst() async {
        let viewModel = makeViewModel(scanner: PhotoLibraryScannerStub(candidates: makeCandidates(["a1", "b2"])))

        await viewModel.load()

        #expect(viewModel.phase == .ready && viewModel.selectedIDs == ["a1", "b2"])
    }

    @Test("写真へのアクセスが許可されていなければ、許可を求める画面にする")
    func showsNotAuthorizedWithoutAccess() async {
        let viewModel = makeViewModel(scanner: PhotoLibraryScannerStub(access: .denied))

        await viewModel.load()

        #expect(viewModel.phase == .notAuthorized)
    }

    @Test("一部の写真だけが許可されていれば、見つからなくてもその理由を出せるようにする")
    func remembersLimitedAccess() async {
        let viewModel = makeViewModel(scanner: PhotoLibraryScannerStub(access: .limited))

        await viewModel.load()

        #expect(viewModel.phase == .empty && viewModel.isAccessLimited)
    }

    @Test("選んだ写真だけを取り込んで画面を閉じる")
    func importsOnlySelectedPhotos() async {
        let repository = PhotoRepositoryMock()
        let viewModel = makeViewModel(
            scanner: PhotoLibraryScannerStub(candidates: makeCandidates(["a1", "b2"])),
            photoRepository: repository
        )
        await viewModel.load()
        viewModel.toggle(viewModel.candidates[1])

        await viewModel.importSelected()

        #expect(repository.saved.count == 1 && viewModel.didImport && !viewModel.isImporting)
    }

    @Test("取り込めない写真があれば知らせ、取り込めた写真は候補から外して二重に保存させない")
    func keepsOnlyFailedPhotosAfterPartialFailure() async {
        let viewModel = makeViewModel(
            scanner: PhotoLibraryScannerStub(candidates: makeCandidates(["a1", "b2"]), unreadableIDs: ["b2"])
        )
        await viewModel.load()

        await viewModel.importSelected()

        #expect(viewModel.notice == .partiallyFailed(count: 1) && !viewModel.didImport)
        #expect(viewModel.candidates.map(\.id) == ["b2"] && viewModel.selectedIDs == ["b2"])
    }

    // MARK: - Private

    private func makeViewModel(
        scanner: PhotoLibraryScannerStub,
        photoRepository: PhotoRepositoryMock = PhotoRepositoryMock()
    ) -> LibraryImportViewModel {
        return LibraryImportViewModel(
            propertyID: property.id,
            fetchProperty: FetchPropertyUseCase(repository: PropertyRepositoryMock(properties: [property])),
            scanLibrary: ScanLibraryPhotosUseCase(scanner: scanner),
            importLibrary: ImportLibraryPhotosUseCase(
                scanner: scanner,
                addPhoto: AddPhotoUseCase(repository: photoRepository, processor: ImageProcessorStub())
            ),
            loadThumbnail: LoadLibraryThumbnailUseCase(scanner: scanner)
        )
    }

    private func makeCandidates(_ ids: [String]) -> [LibraryPhotoCandidate] {
        return ids.enumerated().map { index, id in
            return LibraryPhotoCandidate(id: id, takenAt: property.visitedAt.addingTimeInterval(Double(index) * 60), coordinate: nil)
        }
    }
}
