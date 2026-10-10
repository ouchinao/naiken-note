import Foundation
import SwiftData

/// 公開後はこのスキーマを書き換えないこと。既存のストアが移行なしで開けなくなる。変えるときは SchemaV2 を足す
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
