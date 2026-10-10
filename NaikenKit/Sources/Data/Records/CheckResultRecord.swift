import Foundation
import SwiftData

@Model
final class CheckResultRecord {
    // @Model はプロパティを計算プロパティに置き換えるので、初期値があっても型は省略できない
    var id: UUID = UUID()
    var itemKey: String = ""
    /// `CheckResult.Rating` をそのまま保存しないのは、Domain の型に Codable を求めず、保存形式を Data 層で決めるため
    var rating: Int?
    var note: String = ""
    var property: PropertyRecord?

    init(id: UUID = UUID(), itemKey: String) {
        self.id = id
        self.itemKey = itemKey
    }
}
