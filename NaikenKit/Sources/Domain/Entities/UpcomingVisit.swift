import Foundation

public struct UpcomingVisit: Identifiable, Codable, Hashable, Sendable {
    let propertyID: UUID
    public let name: String
    public let visitAt: Date
    public let nearestStation: String

    public var id: UUID {
        return propertyID
    }

    public init(propertyID: UUID, name: String, visitAt: Date, nearestStation: String) {
        self.propertyID = propertyID
        self.name = name
        self.visitAt = visitAt
        self.nearestStation = nearestStation
    }

    init(property: Property) {
        self.init(
            propertyID: property.id,
            name: property.name,
            visitAt: property.visitedAt,
            nearestStation: property.nearestStation
        )
    }
}

extension UpcomingVisit {
    public static func encode(_ visits: [UpcomingVisit]) throws -> Data {
        return try JSONEncoder().encode(visits)
    }

    public static func decode(_ data: Data) throws -> [UpcomingVisit] {
        return try JSONDecoder().decode([UpcomingVisit].self, from: data)
    }
}
