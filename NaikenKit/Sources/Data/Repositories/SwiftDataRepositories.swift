import Domain
import Foundation
import SwiftData

/// Repository の実装と `ModelContainer` を public にしないのは、App 層を SwiftData の型に依存させないため
public struct SwiftDataRepositories: Sendable {
    public static let cloudKitContainerID = ModelContainerFactory.cloudKitContainerID

    public let properties: any PropertyRepository
    public let photos: any PhotoRepository
    public let measurements: any MeasurementRepository
    public let checkResults: any CheckResultRepository

    init(modelContainer: ModelContainer) {
        properties = SwiftDataPropertyRepository(modelContainer: modelContainer)
        photos = SwiftDataPhotoRepository(modelContainer: modelContainer)
        measurements = SwiftDataMeasurementRepository(modelContainer: modelContainer)
        checkResults = SwiftDataCheckResultRepository(modelContainer: modelContainer)
    }

    public static func make() throws -> SwiftDataRepositories {
        return SwiftDataRepositories(modelContainer: try ModelContainerFactory.make())
    }
}
