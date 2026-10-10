import Foundation

/// ウィジェットに表示する次の内見予定
public struct UpcomingVisit: Identifiable, Codable, Hashable, Sendable {
    public let propertyID: UUID
    public let name: String
    public let visitAt: Date
    public let nearestStation: String
    public let walkMinutes: Int?

    public var id: UUID {
        return propertyID
    }

    public init(propertyID: UUID, name: String, visitAt: Date, nearestStation: String, walkMinutes: Int?) {
        self.propertyID = propertyID
        self.name = name
        self.visitAt = visitAt
        self.nearestStation = nearestStation
        self.walkMinutes = walkMinutes
    }

    public init(property: Property) {
        self.init(
            propertyID: property.id,
            name: property.name,
            visitAt: property.visitedAt,
            nearestStation: property.nearestStation,
            walkMinutes: property.walkMinutes
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
