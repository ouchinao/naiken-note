import Foundation
import Testing
@testable import Domain

struct ScanLibraryPhotosUseCaseTests {
    private let visitAt = Date(timeIntervalSince1970: 1_800_000_000)

    @Test("写真ライブラリへのアクセスが許可されていなければ notAuthorized で失敗する")
    func failsWithoutAuthorization() async {
        let useCase = ScanLibraryPhotosUseCase(scanner: PhotoLibraryScannerMock(access: .denied))

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

    @Test("見つかった写真を、内見日時と撮影地点で絞って撮影順に返す")
    func appliesScanRule() async throws {
        let station = GeoCoordinate(latitude: 35.643_5, longitude: 139.671_0)
        let later = LibraryPhotoCandidate(id: "later", takenAt: visitAt.addingTimeInterval(600), coordinate: nil)
        let anchor = LibraryPhotoCandidate(id: "anchor", takenAt: visitAt, coordinate: station)
        let far = LibraryPhotoCandidate(
            id: "far",
            takenAt: visitAt.addingTimeInterval(300),
            coordinate: GeoCoordinate(latitude: 35.681_2, longitude: 139.767_1)
        )
        let useCase = ScanLibraryPhotosUseCase(scanner: PhotoLibraryScannerMock(candidates: [later, far, anchor]))

        let scan = try await useCase.execute(around: visitAt)

        #expect(scan.candidates.map(\.id) == ["anchor", "later"])
    }

    @Test("一部の写真だけにアクセスが許可されていれば、そのことを返す", arguments: [(PhotoLibraryAccess.limited, true), (.full, false)])
    func reportsLimitedAccess(access: PhotoLibraryAccess, expected: Bool) async throws {
        let useCase = ScanLibraryPhotosUseCase(scanner: PhotoLibraryScannerMock(access: access))

        let scan = try await useCase.execute(around: visitAt)

        #expect(scan.isAccessLimited == expected)
    }
}
