import Domain
import Foundation
import Testing
@testable import Features

@MainActor
struct MeasurementEditorViewModelTests {
    private let propertyID = UUID()

    @Test("寸法が数字でなければ保存せずに知らせる")
    func rejectsNonNumericValue() async {
        let repository = MeasurementRepositoryMock()
        let viewModel = makeViewModel(repository: repository)
        viewModel.label = "窓の幅"
        viewModel.valueText = "百六十九センチ"

        await viewModel.save()

        #expect(isInvalidInput(viewModel.notice) && repository.saved.isEmpty)
    }

    @Test("どこの寸法かが空なら保存せずに知らせる")
    func rejectsEmptyLabel() async {
        let repository = MeasurementRepositoryMock()
        let viewModel = makeViewModel(repository: repository)
        viewModel.valueText = "1690"

        await viewModel.save()

        #expect(isInvalidInput(viewModel.notice) && repository.saved.isEmpty)
    }

    @Test("登録済みの採寸を直すと、同じ採寸として登録日時を保ったまま保存する")
    func editsExistingMeasurement() async {
        let measurement = Measurement(
            id: UUID(),
            label: "窓の幅",
            valueMillimeters: 1_690,
            note: "レールの内側",
            createdAt: Date(timeIntervalSince1970: 1_800_000_000)
        )
        let property = Property(id: propertyID, name: "A棟201", visitedAt: Date(), measurements: [measurement], createdAt: Date())
        let repository = MeasurementRepositoryMock()
        let viewModel = makeViewModel(repository: repository, properties: [property], measurementID: measurement.id)
        await viewModel.load()
        viewModel.valueText = "1700"

        await viewModel.save()

        let saved = repository.saved.first
        #expect(saved?.id == measurement.id && saved?.createdAt == measurement.createdAt)
        #expect(saved?.valueMillimeters == 1_700 && saved?.note == "レールの内側" && viewModel.didSave)
    }

    // MARK: - Private

    private func makeViewModel(
        repository: MeasurementRepositoryMock,
        properties: [Property] = [],
        measurementID: UUID? = nil
    ) -> MeasurementEditorViewModel {
        return MeasurementEditorViewModel(
            propertyID: propertyID,
            measurementID: measurementID,
            fetchProperty: FetchPropertyUseCase(repository: PropertyRepositoryMock(properties: properties)),
            saveMeasurement: SaveMeasurementUseCase(repository: repository)
        )
    }

    private func isInvalidInput(_ notice: MeasurementEditorViewModel.Notice?) -> Bool {
        if case .invalidInput = notice {
            return true
        }
        return false
    }
}
