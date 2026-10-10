import Foundation

public struct GeoCoordinate: Hashable, Sendable {
    private static let earthRadiusMeters = 6_371_000.0

    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    /// 2点間の大円距離(メートル)
    public func distance(to other: GeoCoordinate) -> Double {
        let fromLatitude = latitude * .pi / 180
        let toLatitude = other.latitude * .pi / 180
        let deltaLatitude = (other.latitude - latitude) * .pi / 180
        let deltaLongitude = (other.longitude - longitude) * .pi / 180
        let haversine = sin(deltaLatitude / 2) * sin(deltaLatitude / 2)
            + cos(fromLatitude) * cos(toLatitude) * sin(deltaLongitude / 2) * sin(deltaLongitude / 2)
        let angle = 2 * atan2(sqrt(haversine), sqrt(1 - haversine))
        return Self.earthRadiusMeters * angle
    }
}
