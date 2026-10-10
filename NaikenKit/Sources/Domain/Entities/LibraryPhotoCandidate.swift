import Foundation

public struct LibraryPhotoCandidate: Identifiable, Hashable, Sendable {
    public let id: String
    public let takenAt: Date
    let coordinate: GeoCoordinate?

    public init(id: String, takenAt: Date, coordinate: GeoCoordinate?) {
        self.id = id
        self.takenAt = takenAt
        self.coordinate = coordinate
    }
}
