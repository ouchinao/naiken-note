import Foundation
@testable import Domain

extension Property {
    static func fixture(
        name: String = "テスト物件",
        visitedAt: Date = Date(timeIntervalSince1970: 1_800_000_000),
        photos: [Photo] = [],
        measurements: [Measurement] = [],
        checkResults: [CheckResult] = [],
        customerID: UUID? = nil
    ) -> Property {
        return Property(
            id: UUID(),
            name: name,
            visitedAt: visitedAt,
            photos: photos,
            measurements: measurements,
            checkResults: checkResults,
            customerID: customerID,
            createdAt: Date(timeIntervalSince1970: 1_800_000_000)
        )
    }
}

extension Photo {
    static func fixture(sortOrder: Int, roomTag: RoomTag = .living) -> Photo {
        return Photo(
            id: UUID(),
            roomTag: roomTag,
            takenAt: Date(timeIntervalSince1970: 1_800_000_000),
            sortOrder: sortOrder
        )
    }
}
