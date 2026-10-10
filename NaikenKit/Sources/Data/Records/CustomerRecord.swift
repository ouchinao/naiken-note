import Foundation
import SwiftData

/// Pro(2.0)の顧客別フォルダ。リリース後にスキーマを移行しなくて済むよう、1.0 のスキーマから含めておく
@Model
final class CustomerRecord {
    var id: UUID = UUID()
    var name: String = ""
    var memo: String = ""
    var createdAt: Date = Date()

    /// 顧客を消しても物件は残し、未分類に戻す
    @Relationship(deleteRule: .nullify, inverse: \PropertyRecord.customer)
    var properties: [PropertyRecord]? = []

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
