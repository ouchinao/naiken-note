import Domain
import Foundation
import Testing
@testable import Features

@MainActor
struct ChecklistTabViewModelTests {
    private let item = CheckItemCatalog.all[0]
    private let property = Property(id: UUID(), name: "A棟201", visitedAt: Date(), createdAt: Date())

    @Test("評価のすぐあとにメモを書いても、評価を消さずに保存する")
    func noteKeepsRatingSavedJustBefore() async {
        let repository = CheckResultRepositoryMock()
        let viewModel = makeViewModel(repository: repository)
        await viewModel.setRating(.good, for: item, in: property)
        viewModel.editNote("南向き", for: item)

        await viewModel.commitNote(for: item, in: property)

        #expect(repository.saved.last?.rating == .good && repository.saved.last?.note == "南向き")
    }

    @Test("入力中のメモは、保存する前でも表示し続ける")
    func showsDraftBeforeSaving() {
        let viewModel = makeViewModel(repository: CheckResultRepositoryMock())

        viewModel.editNote("西日が強い", for: item)

        #expect(viewModel.note(for: item, in: property) == "西日が強い")
    }

    @Test("保存したメモは、物件を読み直す前でも表示し続ける")
    func showsSavedNoteBeforeReload() async {
        let viewModel = makeViewModel(repository: CheckResultRepositoryMock())
        viewModel.editNote("西日が強い", for: item)

        await viewModel.commitNote(for: item, in: property)

        #expect(viewModel.note(for: item, in: property) == "西日が強い")
    }

    @Test("メモを書き換えていなければ保存しない")
    func doesNotSaveWithoutEditing() async {
        let repository = CheckResultRepositoryMock()
        let viewModel = makeViewModel(repository: repository)

        await viewModel.commitNote(for: item, in: property)

        #expect(repository.saved.isEmpty)
    }

    @Test("読み直した物件に保存した内容が届いたら、その後の別の端末での変更を表示する")
    func followsLaterChangesAfterReload() async {
        let viewModel = makeViewModel(repository: CheckResultRepositoryMock())
        await viewModel.setRating(.good, for: item, in: property)
        viewModel.didReload(reloaded(rating: .good))

        let changedElsewhere = reloaded(rating: .bad)

        #expect(viewModel.result(for: item, in: changedElsewhere)?.rating == .bad)
    }

    @Test("保存に失敗したら知らせ、評価の表示を元に戻す")
    func revertsRatingWhenSaveFails() async {
        let viewModel = makeViewModel(repository: CheckResultRepositoryMock(failure: TestFailure.stubbed))

        await viewModel.setRating(.good, for: item, in: property)

        #expect(viewModel.notice != nil && viewModel.result(for: item, in: property) == nil)
    }

    // MARK: - Private

    private func makeViewModel(repository: CheckResultRepositoryMock) -> ChecklistTabViewModel {
        return ChecklistTabViewModel(saveCheckResult: SaveCheckResultUseCase(repository: repository))
    }

    private func reloaded(rating: CheckResult.Rating) -> Property {
        return Property(
            id: property.id,
            name: property.name,
            visitedAt: property.visitedAt,
            checkResults: [CheckResult(id: UUID(), itemKey: item.id, rating: rating)],
            createdAt: property.createdAt
        )
    }
}
