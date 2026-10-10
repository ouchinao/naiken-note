import Foundation
import SwiftData

public enum ModelContainerFactory {
    private static let cloudKitContainerID = "iCloud.com.example.naikennote"

    /// `inMemory: true` はテストとSwiftUIプレビュー用。CloudKitを切り、ディスクにも書かない
    public static func make(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: SchemaV1.self)
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: inMemory ? .none : .private(cloudKitContainerID)
        )
        return try ModelContainer(
            for: schema,
            migrationPlan: NaikenMigrationPlan.self,
            configurations: [configuration]
        )
    }
}
