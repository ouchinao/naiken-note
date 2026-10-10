import Foundation
import SwiftData

@Model
final class CheckResultRecord {
    var id: UUID = UUID()
    var itemKey: String = ""
    /// `CheckResult.Rating` の rawValue。未評価ならnil
    var rating: Int?
    var note: String = ""
    var property: PropertyRecord?

    init(id: UUID = UUID(), itemKey: String) {
        self.id = id
        self.itemKey = itemKey
    }
}
