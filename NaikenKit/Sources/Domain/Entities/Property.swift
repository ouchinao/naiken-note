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
