import Foundation
import SwiftData

/// 1.0時点のスキーマ。リリース後の変更は追加のみとし、変更するときは SchemaV2 を切る
enum SchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        return Schema.Version(1, 0, 0)
    }

    static var models: [any PersistentModel.Type] {
        return [
            PropertyRecord.self,
            PhotoRecord.self,
            MeasurementRecord.self,
            CheckResultRecord.self,
            CustomerRecord.self,
        ]
    }
}
