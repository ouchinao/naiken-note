import Foundation
import Testing
@testable import Domain

struct LibraryScanRuleTests {
    private let visitAt = Date(timeIntervalSince1970: 1_800_000_000)
    private let station = GeoCoordinate(latitude: 35.643_5, longitude: 139.671_0)
    private let farAway = GeoCoordinate(latitude: 35.681_2, longitude: 139.767_1)

    @Test("内見日時の前後1時間より外の写真は除く")
    func excludesPhotosOutsideWindow() {
        let inside = LibraryPhotoCandidate(id: "inside", takenAt: visitAt.addingTimeInterval(-3_000), coordinate: nil)
        let outside = LibraryPhotoCandidate(id: "outside", takenAt: visitAt.addingTimeInterval(4_000), coordinate: nil)

        let result = LibraryScanRule.filter([inside, outside], around: visitAt)

        #expect(result.map(\.id) == ["inside"])
    }

    @Test("ちょうど1時間前と1時間後に撮った写真は残す")
    func keepsPhotosAtWindowEdges() {
        let before = LibraryPhotoCandidate(id: "before", takenAt: visitAt.addingTimeInterval(-3_600), coordinate: nil)
        let after = LibraryPhotoCandidate(id: "after", takenAt: visitAt.addingTimeInterval(3_600), coordinate: nil)

        let result = LibraryScanRule.filter([before, after], around: visitAt)

        #expect(result.map(\.id) == ["before", "after"])
    }

    @Test("内見場所から500mまでの写真は残し、それより離れた写真は除く")
    func keepsPhotosWithin500Meters() {
        let anchor = LibraryPhotoCandidate(id: "anchor", takenAt: visitAt, coordinate: station)
        let near = LibraryPhotoCandidate(id: "near", takenAt: visitAt.addingTimeInterval(60), coordinate: north(of: station, meters: 499))
        let beyond = LibraryPhotoCandidate(
            id: "beyond",
            takenAt: visitAt.addingTimeInterval(120),
            coordinate: north(of: station, meters: 501)
        )

        let result = LibraryScanRule.filter([anchor, near, beyond], around: visitAt)

        #expect(result.map(\.id) == ["anchor", "near"])
    }

    @Test("内見日時に最も近い写真の撮影地点から離れた写真は除く")
    func excludesFarPhotos() {
        let anchor = LibraryPhotoCandidate(id: "anchor", takenAt: visitAt, coordinate: station)
        let far = LibraryPhotoCandidate(id: "far", takenAt: visitAt.addingTimeInterval(600), coordinate: farAway)

        let result = LibraryScanRule.filter([anchor, far], around: visitAt)

        #expect(result.map(\.id) == ["anchor"])
    }

    @Test("位置情報のない写真は残す")
    func keepsPhotosWithoutLocation() {
        let anchor = LibraryPhotoCandidate(id: "anchor", takenAt: visitAt, coordinate: station)
        let unknown = LibraryPhotoCandidate(id: "unknown", takenAt: visitAt.addingTimeInterval(60), coordinate: nil)

        let result = LibraryScanRule.filter([anchor, unknown], around: visitAt)

        #expect(result.map(\.id) == ["anchor", "unknown"])
    }

    @Test("撮影順に並べる")
    func sortsByTakenAt() {
        let later = LibraryPhotoCandidate(id: "later", takenAt: visitAt.addingTimeInterval(120), coordinate: nil)
        let earlier = LibraryPhotoCandidate(id: "earlier", takenAt: visitAt.addingTimeInterval(-120), coordinate: nil)

        let result = LibraryScanRule.filter([later, earlier], around: visitAt)

        #expect(result.map(\.id) == ["earlier", "later"])
    }

    // MARK: - Private

    private func north(of coordinate: GeoCoordinate, meters: Double) -> GeoCoordinate {
        let metersPerDegreeOfLatitude = 111_195.0
        return GeoCoordinate(latitude: coordinate.latitude + meters / metersPerDegreeOfLatitude, longitude: coordinate.longitude)
    }
}
