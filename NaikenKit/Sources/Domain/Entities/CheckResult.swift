import Foundation

public struct CheckResult: Identifiable, Hashable, Sendable {
    public enum Rating: Int, CaseIterable, Sendable {
        case bad = 1
        case neutral = 2
        case good = 3
    }

    public let id: UUID
    public let itemKey: String
    public var rating: Rating?
    public var note: String

    public init(id: UUID, itemKey: String, rating: Rating? = nil, note: String = "") {
        self.id = id
        self.itemKey = itemKey
        self.rating = rating
        self.note = note
    }
}
