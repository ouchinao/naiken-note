import Domain
import Foundation

// ロックを省かないのは、@unchecked Sendable でコンパイラによる並行アクセスのチェックを外しているため
final class MeasurementRepositoryMock: MeasurementRepository, @unchecked Sendable {
    private(set) var saved: [Measurement] = []

    private let lock = NSLock()

    func save(_ measurement: Measurement, propertyID _: UUID) async throws {
        lock.withLock {
            saved.append(measurement)
        }
    }

    func delete(id _: UUID) async throws {}
}
