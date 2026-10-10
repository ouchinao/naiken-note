import Foundation
import Testing
@testable import Domain

struct PropertyTests {
    private let takenAt = Date(timeIntervalSince1970: 1_800_000_000)

    @Test("並び順が同じ写真は撮影日時の早い順に並べ、先頭を代表写真にする")
    func ordersTiedPhotosByTakenAt() {
        let later = Photo(id: UUID(), roomTag: .living, takenAt: takenAt.addingTimeInterval(60), sortOrder: 0)
        let earlier = Photo(id: UUID(), roomTag: .kitchen, takenAt: takenAt, sortOrder: 0)

        let property = Property.fixture(photos: [later, earlier])

        #expect(property.photos.map(\.id) == [earlier.id, later.id])
        #expect(property.representativePhoto == earlier)
    }

    @Test("並び順も撮影日時も同じ写真は、届いた順によらず同じ順に並べる")
    func ordersFullyTiedPhotosTheSameWay() {
        let photos = (0..<3).map { _ in
            return Photo(id: UUID(), roomTag: .other, takenAt: takenAt, sortOrder: 0)
        }

        let forward = Property.fixture(photos: photos)
        let backward = Property.fixture(photos: photos.reversed())

        #expect(forward.photos == backward.photos)
    }

    @Test("採寸は登録した順に並べる")
    func ordersMeasurementsByCreation() {
        let second = Measurement(id: UUID(), label: "窓の高さ", valueMillimeters: 1_200, createdAt: takenAt.addingTimeInterval(60))
        let first = Measurement(id: UUID(), label: "窓の幅", valueMillimeters: 1_690, createdAt: takenAt)

        let property = Property.fixture(measurements: [second, first])

        #expect(property.measurements.map(\.id) == [first.id, second.id])
    }

    @Test("同じ項目のチェック結果が2件届いても1件として数える")
    func countsOneResultPerItem() {
        let results = [
            CheckResult(id: UUID(), itemKey: "noise", rating: .good),
            CheckResult(id: UUID(), itemKey: "noise", rating: .good),
            CheckResult(id: UUID(), itemKey: "sunlight", rating: .good),
        ]

        let property = Property.fixture(checkResults: results)

        #expect(property.checkResults.count == 2)
        #expect(property.goodCount == 2)
    }

    @Test("同じ項目のチェック結果が2件届いても、届いた順によらず同じ結果を表示する")
    func showsTheSameDuplicateRegardlessOfOrder() {
        let good = CheckResult(id: UUID(), itemKey: "noise", rating: .good)
        let bad = CheckResult(id: UUID(), itemKey: "noise", rating: .bad)

        let forward = Property.fixture(checkResults: [good, bad])
        let backward = Property.fixture(checkResults: [bad, good])

        #expect(forward.checkResult(forItemKey: "noise") == backward.checkResult(forItemKey: "noise"))
    }

    @Test("比較表の○の数は、○を付けた項目の数")
    func goodCountCountsGoodRatings() {
        let results = [
            CheckResult(id: UUID(), itemKey: "noise", rating: .good),
            CheckResult(id: UUID(), itemKey: "sunlight", rating: .neutral),
            CheckResult(id: UUID(), itemKey: "smell", rating: .bad),
            CheckResult(id: UUID(), itemKey: "view"),
        ]

        #expect(Property.fixture(checkResults: results).goodCount == 1)
    }
}
