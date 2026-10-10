import Foundation

public struct Property: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let rent: Int?
    public let layout: String
    public let areaSquareMeters: Double?
    public let nearestStation: String
    public let walkMinutes: Int?
    public let visitedAt: Date
    public let memo: String
    public let photos: [Photo]
    public let measurements: [Measurement]
    public let checkResults: [CheckResult]
    public let customerID: UUID?
    public let createdAt: Date

    public init(
        id: UUID,
        name: String,
        rent: Int? = nil,
        layout: String = "",
        areaSquareMeters: Double? = nil,
        nearestStation: String = "",
        walkMinutes: Int? = nil,
        visitedAt: Date,
        memo: String = "",
        photos: [Photo] = [],
        measurements: [Measurement] = [],
        checkResults: [CheckResult] = [],
        customerID: UUID? = nil,
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.rent = rent
        self.layout = layout
        self.areaSquareMeters = areaSquareMeters
        self.nearestStation = nearestStation
        self.walkMinutes = walkMinutes
        self.visitedAt = visitedAt
        self.memo = memo
        self.photos = photos.sorted(by: Photo.displayOrder)
        self.measurements = measurements.sorted(by: Measurement.displayOrder)
        self.checkResults = CheckResult.onePerItem(checkResults)
        self.customerID = customerID
        self.createdAt = createdAt
    }
}

extension Property {
    public var representativePhoto: Photo? {
        return photos.first
    }

    public var goodCount: Int {
        return checkResults.filter { $0.rating == .good }.count
    }

    public func checkResult(forItemKey itemKey: String) -> CheckResult? {
        return checkResults.first { $0.itemKey == itemKey }
    }
}
