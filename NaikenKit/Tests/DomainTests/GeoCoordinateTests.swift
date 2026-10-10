import Foundation
import Testing
@testable import Domain

struct GeoCoordinateTests {
    @Test("東京駅から新宿駅までは約6.1km")
    func distanceBetweenStations() {
        let tokyo = GeoCoordinate(latitude: 35.681_236, longitude: 139.767_125)
        let shinjuku = GeoCoordinate(latitude: 35.690_921, longitude: 139.700_258)

        let distance = tokyo.distance(to: shinjuku)

        #expect((6_000...6_300).contains(distance))
    }

    @Test("同じ地点の距離は0")
    func samePointIsZero() {
        let point = GeoCoordinate(latitude: 35.0, longitude: 139.0)

        #expect(point.distance(to: point) == 0)
    }
}
