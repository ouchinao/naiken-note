import Foundation

public protocol CheckResultRepository: Sendable {
    /// 物件ごとに `itemKey` が同じ結果があれば上書きする
    func save(_ result: CheckResult, propertyID: UUID) async throws
}
