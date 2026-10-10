import Domain
import Foundation
import SwiftData

@ModelActor
actor SwiftDataCheckResultRepository: CheckResultRepository {
    func save(_ result: CheckResult, propertyID: UUID) throws {
        guard let property = try modelContext.propertyRecord(id: propertyID) else {
            throw RepositoryError.propertyNotFound
        }
        let sameItem = (property.checkResults ?? [])
            .filter { $0.itemKey == result.itemKey }
            .sorted { $0.id.uuidString < $1.id.uuidString }
        let record = sameItem.first { $0.id == result.id } ?? sameItem.first ?? makeRecord(for: result, in: property)
        record.apply(result)
        // 余分な結果を残さないのは、2台の端末で同期前に同じ項目を評価してできた重複を、次に保存したときに解消するため
        for duplicate in sameItem where duplicate !== record {
            modelContext.delete(duplicate)
        }
        try modelContext.commit()
    }

    // MARK: - Private

    private func makeRecord(for result: CheckResult, in property: PropertyRecord) -> CheckResultRecord {
        let record = CheckResultRecord(id: result.id, itemKey: result.itemKey)
        modelContext.insert(record)
        record.property = property
        return record
    }
}
