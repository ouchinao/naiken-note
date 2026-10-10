import Domain
import Foundation
import SwiftData

/// App層が Repository の具象型を知らずに済むよう、SwiftData実装をまとめて生成する
public struct SwiftDataRepositories: Sendable {
    public let properties: any PropertyRepository
    public let photos: any PhotoRepository
    public let measurements: any MeasurementRepository
    public let checkResults: any CheckResultRepository
    public let customers: any CustomerRepository

    public init(modelContainer: ModelContainer) {
        properties = SwiftDataPropertyRepository(modelContainer: modelContainer)
        photos = SwiftDataPhotoRepository(modelContainer: modelContainer)
        measurements = SwiftDataMeasurementRepository(modelContainer: modelContainer)
        checkResults = SwiftDataCheckResultRepository(modelContainer: modelContainer)
        customers = SwiftDataCustomerRepository(modelContainer: modelContainer)
    }
}
