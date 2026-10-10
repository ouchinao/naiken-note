import Foundation

public protocol PropertyRepository: Sendable {
    func fetchAll() async throws -> [Property]
    /// 全件を読んでから絞らないのは、起動直後に一覧の読み込みと同じ actor で全物件の写真や採寸まで読み、一覧の表示を遅らせないため
    func fetchAll(visitedAfter date: Date) async throws -> [Property]
    func fetch(id: UUID) async throws -> Property?
    func count() async throws -> Int
    /// 写真・採寸・チェック結果をここで保存しないのは、物件を編集するたびに画像を含む子レコードまで書き直さないため
    func save(_ property: Property) async throws
    func delete(id: UUID) async throws
}
