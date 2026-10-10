import Foundation
import SwiftData

/// 使うのは 2.0 の顧客別フォルダだが、1.0 のスキーマから含めておくのは、公開後のスキーマ移行を避けるため
@Model
final class CustomerRecord {
    // @Model はプロパティを計算プロパティに置き換えるので、初期値があっても型は省略できない
    var id: UUID = UUID()
    var name: String = ""
    var memo: String = ""
    var createdAt: Date = Date()

    /// cascade にしないのは、顧客を消しても物件の記録は残すため
    @Relationship(deleteRule: .nullify, inverse: \PropertyRecord.customer)
    var properties: [PropertyRecord]? = []

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
