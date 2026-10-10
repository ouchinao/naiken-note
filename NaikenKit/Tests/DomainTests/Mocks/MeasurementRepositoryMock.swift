import Foundation
@testable import Domain

// ロックを省かないのは、@unchecked Sendable でコンパイラによる並行アクセスのチェックを外しているため
final class MeasurementRepositoryMock: MeasurementRepository, @unchecked Sendable {
    private(set) var saved: [Measurement] = []
    private(set) var deletedIDs: [UUID] = []

    private let lock = NSLock()

    func save(_ measurement: Measurement, propertyID _: UUID) async throws {
        lock.withLock {
            saved.append(measurement)
        }
    }

    func delete(id: UUID) async throws {
        lock.withLock {
            deletedIDs.append(id)
        }
    }
}
