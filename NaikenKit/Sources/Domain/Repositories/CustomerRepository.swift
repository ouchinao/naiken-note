import Foundation

public protocol CustomerRepository: Sendable {
    /// 名前順に返す
    func fetchAll() async throws -> [Customer]
    func save(_ customer: Customer) async throws
    /// 顧客を削除する。属していた物件は消さず、未分類に戻す
    func delete(id: UUID) async throws
}
