import Domain
import Foundation

// テストからは逐次呼ぶだけだが、記録はロックで守ってから @unchecked Sendable にする
final class PropertyRepositoryMock: PropertyRepository, @unchecked Sendable {
    private(set) var saved: [Property] = []

    private let lock = NSLock()
    private let countValue: Int
    private let properties: [Property]

    init(count: Int = 0, properties: [Property] = []) {
        countValue = count
        self.properties = properties
    }

    func fetchAll() async throws -> [Property] {
        return properties
    }

    func fetch(id: UUID) async throws -> Property? {
        return properties.first { $0.id == id }
    }

    func count() async throws -> Int {
        return countValue
    }

    func save(_ property: Property) async throws {
        lock.withLock {
            saved.append(property)
        }
    }

    func delete(id _: UUID) async throws {}
}
