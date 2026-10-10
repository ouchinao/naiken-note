import Foundation
@testable import Domain

// テストからは逐次呼ぶだけだが、記録はロックで守ってから @unchecked Sendable にする
final class MeasurementRepositoryMock: MeasurementRepository, @unchecked Sendable {
    private(set) var saved: [Measurement] = []
    private(set) var deletedIDs: [UUID] = []

    private let lock = NSLock()

    func save(_ measurement: Measurement, propertyID: UUID) async throws {
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
