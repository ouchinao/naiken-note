import Domain
import Foundation
import SwiftData

@ModelActor
actor SwiftDataPropertyRepository: PropertyRepository {
    func fetchAll() throws -> [Property] {
        return try modelContext.fetch(FetchDescriptor<PropertyRecord>()).map(Property.init(record:))
    }

    func fetchAll(visitedAfter date: Date) throws -> [Property] {
        let descriptor = FetchDescriptor<PropertyRecord>(predicate: #Predicate { $0.visitedAt > date })
        return try modelContext.fetch(descriptor).map(Property.init(record:))
    }

    func fetch(id: UUID) throws -> Property? {
        return try modelContext.propertyRecord(id: id).map(Property.init(record:))
    }

    func count() throws -> Int {
        return try modelContext.fetchCount(FetchDescriptor<PropertyRecord>())
    }

    func save(_ property: Property) throws {
        let record = try modelContext.propertyRecord(id: property.id) ?? PropertyRecord(
            id: property.id,
            name: property.name,
            visitedAt: property.visitedAt
        )
        modelContext.insert(record)
        record.apply(property)
        try modelContext.commit()
    }

    func delete(id: UUID) throws {
        guard let record = try modelContext.propertyRecord(id: id) else {
            return
        }
        modelContext.delete(record)
        try modelContext.commit()
    }
}
