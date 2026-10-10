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

extension CheckResult {
    /// 届いた結果をそのまま並べないのは、2台の端末で同期前に同じ項目を評価すると同じ項目の結果が2件届き、○の数を数え違えるため
    static func onePerItem(_ results: [CheckResult]) -> [CheckResult] {
        var kept: [String: CheckResult] = [:]
        for result in results {
            if let current = kept[result.itemKey], current.id.uuidString <= result.id.uuidString {
                continue
            }
            kept[result.itemKey] = result
        }
        return kept.values.sorted { $0.itemKey < $1.itemKey }
    }
}
