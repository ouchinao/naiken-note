import Domain
import Foundation

extension Customer {
    init(record: CustomerRecord) {
        self.init(
            id: record.id,
            name: record.name,
            memo: record.memo,
            createdAt: record.createdAt
        )
    }
}

extension CustomerRecord {
    func apply(_ customer: Customer) {
        name = customer.name
        memo = customer.memo
        createdAt = customer.createdAt
    }
}
