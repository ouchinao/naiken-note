import Foundation
import SwiftData

@Model
final class MeasurementRecord {
    // @Model はプロパティを計算プロパティに置き換えるので、初期値があっても型は省略できない
    var id: UUID = UUID()
    var label: String = ""
    var valueMillimeters: Int = 0
    var note: String = ""
    var photoID: UUID?
    var createdAt: Date = Date()
    var property: PropertyRecord?

    init(id: UUID = UUID(), label: String, valueMillimeters: Int) {
        self.id = id
        self.label = label
        self.valueMillimeters = valueMillimeters
    }
}
