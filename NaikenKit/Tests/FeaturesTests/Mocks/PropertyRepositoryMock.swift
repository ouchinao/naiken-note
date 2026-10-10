import Domain
import Foundation

// ロックを省かないのは、@unchecked Sendable でコンパイラによる並行アクセスのチェックを外しているため
final class PropertyRepositoryMock: PropertyRepository, @unchecked Sendable {
    private(set) var saved: [Property] = []

    private let lock = NSLock()
    private let countValue: Int
    private let properties: [Property]
    private let failure: (any Error)?

    init(count: Int = 0, properties: [Property] = [], failure: (any Error)? = nil) {
        countValue = count
        self.properties = properties
        self.failure = failure
    }

    func fetchAll() async throws -> [Property] {
        if let failure {
            throw failure
        }
        return properties
    }

    func fetchAll(visitedAfter date: Date) async throws -> [Property] {
        return try await fetchAll().filter { $0.visitedAt > date }
    }

    func fetch(id: UUID) async throws -> Property? {
        if let failure {
            throw failure
        }
        return properties.first { $0.id == id }
    }

    func count() async throws -> Int {
        return countValue
    }

    func save(_ property: Property) async throws {
        if let failure {
            throw failure
        }
        lock.withLock {
            saved.append(property)
        }
    }

    func delete(id _: UUID) async throws {}
}
