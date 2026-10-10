import Foundation
import Testing
@testable import Domain

struct ScanLibraryPhotosUseCaseTests {
    private let visitAt = Date(timeIntervalSince1970: 1_800_000_000)

    @Test("写真ライブラリの権限がなければ notAuthorized で失敗する")
    func failsWithoutAuthorization() async {
        let useCase = ScanLibraryPhotosUseCase(scanner: PhotoLibraryScannerMock(isAuthorized: false))

        await #expect(throws: ScanLibraryPhotosUseCase.Failure.notAuthorized) {
            try await useCase.execute(around: visitAt)
        }
    }

    @Test("内見日時の前後1時間を探す")
    func scansOneHourAroundVisit() async throws {
        let scanner = PhotoLibraryScannerMock()
        let useCase = ScanLibraryPhotosUseCase(scanner: scanner)

        _ = try await useCase.execute(around: visitAt)

        let expectedRange = [visitAt.addingTimeInterval(-3_600), visitAt.addingTimeInterval(3_600)]
        #expect(scanner.requestedStarts + scanner.requestedEnds == expectedRange)
    }
}
