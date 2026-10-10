import Domain
import Foundation
import SwiftData

@ModelActor
actor SwiftDataCustomerRepository: CustomerRepository {
    func fetchAll() throws -> [Customer] {
        return try modelContext.fetch(FetchDescriptor<CustomerRecord>()).map(Customer.init(record:))
    }

    func save(_ customer: Customer) throws {
        let record = try modelContext.customerRecord(id: customer.id) ?? CustomerRecord(
            id: customer.id,
            name: customer.name
        )
        modelContext.insert(record)
        record.apply(customer)
        try modelContext.commit()
    }

    func delete(id: UUID) throws {
        guard let record = try modelContext.customerRecord(id: id) else {
            return
        }
        modelContext.delete(record)
        try modelContext.commit()
    }
}
