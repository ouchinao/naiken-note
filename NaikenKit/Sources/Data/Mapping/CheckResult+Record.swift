import Domain
import Foundation

extension CheckResult {
    init(record: CheckResultRecord) {
        self.init(
            id: record.id,
            itemKey: record.itemKey,
            rating: record.rating.flatMap(Rating.init(rawValue:)),
            note: record.note
        )
    }
}

extension CheckResultRecord {
    func apply(_ result: CheckResult) {
        rating = result.rating?.rawValue
        note = result.note
    }
}
