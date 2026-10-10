import Domain
import Foundation
import SwiftData

/// Repository の実装を public にしないのは、App 層を SwiftData の型に依存させないため
public struct SwiftDataRepositories: Sendable {
    public let properties: any PropertyRepository
    public let photos: any PhotoRepository
    public let measurements: any MeasurementRepository
    public let checkResults: any CheckResultRepository

    public init(modelContainer: ModelContainer) {
        properties = SwiftDataPropertyRepository(modelContainer: modelContainer)
        photos = SwiftDataPhotoRepository(modelContainer: modelContainer)
        measurements = SwiftDataMeasurementRepository(modelContainer: modelContainer)
        checkResults = SwiftDataCheckResultRepository(modelContainer: modelContainer)
    }
}
