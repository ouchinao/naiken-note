import Foundation
import Testing
@testable import Domain

struct SaveMeasurementUseCaseTests {
    @Test("ラベルが空なら emptyLabel で失敗する")
    func rejectsEmptyLabel() async {
        let useCase = SaveMeasurementUseCase(repository: MeasurementRepositoryMock())
        let measurement = Measurement(id: UUID(), label: "  ", valueMillimeters: 1_200, createdAt: Date())

        await #expect(throws: SaveMeasurementUseCase.Failure.emptyLabel) {
            try await useCase.execute(measurement, propertyID: UUID())
        }
    }

    @Test("寸法が0以下なら invalidValue で失敗する", arguments: [0, -10])
    func rejectsNonPositiveValue(value: Int) async {
        let useCase = SaveMeasurementUseCase(repository: MeasurementRepositoryMock())
        let measurement = Measurement(id: UUID(), label: "窓の幅", valueMillimeters: value, createdAt: Date())

        await #expect(throws: SaveMeasurementUseCase.Failure.invalidValue) {
            try await useCase.execute(measurement, propertyID: UUID())
        }
    }

    @Test("正しい採寸メモは保存する")
    func savesValidMeasurement() async throws {
        let repository = MeasurementRepositoryMock()
        let useCase = SaveMeasurementUseCase(repository: repository)
        let measurement = Measurement(id: UUID(), label: "窓の幅", valueMillimeters: 1_690, createdAt: Date())

        try await useCase.execute(measurement, propertyID: UUID())

        #expect(repository.saved == [measurement])
    }
}
