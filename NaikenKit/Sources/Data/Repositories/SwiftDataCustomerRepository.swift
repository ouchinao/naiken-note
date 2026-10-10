import Domain
import Foundation
import SwiftData

@ModelActor
actor SwiftDataCustomerRepository: CustomerRepository {
    func fetchAll() throws -> [Customer] {
        let descriptor = FetchDescriptor<CustomerRecord>(
            sortBy: [SortDescriptor(\.name, comparator: .localizedStandard)]
        )
        return try modelContext.fetch(descriptor).map(Customer.init(record:))
    }

    func save(_ customer: Customer) throws {
        let record = try modelContext.customerRecord(id: customer.id) ?? CustomerRecord(
            id: customer.id,
            name: customer.name
        )
        modelContext.insert(record)
        record.apply(customer)
        try modelContext.save()
        StoreChangeObserver.postLocalChange()
    }

    func delete(id: UUID) throws {
        guard let record = try modelContext.customerRecord(id: id) else {
            return
        }
        modelContext.delete(record)
        try modelContext.save()
        StoreChangeObserver.postLocalChange()
    }
}
