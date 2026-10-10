import Foundation

public protocol PropertyRepository: Sendable {
    /// 内見日の新しい順に返す
    func fetchAll() async throws -> [Property]
    func fetch(id: UUID) async throws -> Property?
    func count() async throws -> Int
    /// 物件そのものの項目だけを保存する。写真・採寸・チェック結果はそれぞれのRepositoryで保存する
    func save(_ property: Property) async throws
    func delete(id: UUID) async throws
}
