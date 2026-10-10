import Foundation

public struct Property: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var rent: Int?
    public var layout: String
    public var areaSquareMeters: Double?
    public var nearestStation: String
    public var walkMinutes: Int?
    public var visitedAt: Date
    public var memo: String
    public var photos: [Photo]
    public var measurements: [Measurement]
    public var checkResults: [CheckResult]
    public var customerID: UUID?
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
        self.photos = photos
        self.measurements = measurements
        self.checkResults = checkResults
        self.customerID = customerID
        self.createdAt = createdAt
    }
}

extension Property {
    /// 比較表やリストで使う代表写真。並び順の先頭を代表とする
    public var representativePhoto: Photo? {
        return photos.min { $0.sortOrder < $1.sortOrder }
    }

    /// チェックリストで「○」を付けた項目の数
    public var goodCount: Int {
        return checkResults.filter { $0.rating == .good }.count
    }

    public func checkResult(forItemKey itemKey: String) -> CheckResult? {
        return checkResults.first { $0.itemKey == itemKey }
    }
}
