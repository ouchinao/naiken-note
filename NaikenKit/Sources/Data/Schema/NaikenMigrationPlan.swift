import Foundation
import SwiftData

enum NaikenMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        return [SchemaV1.self]
    }

    static var stages: [MigrationStage] {
        return []
    }
}
