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
}
