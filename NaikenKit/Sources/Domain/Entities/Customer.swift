import Foundation

/// Proモードの顧客別フォルダ
public struct Customer: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public let memo: String
    public let createdAt: Date

    public init(id: UUID, name: String, memo: String = "", createdAt: Date) {
        self.id = id
        self.name = name
        self.memo = memo
        self.createdAt = createdAt
    }
}
