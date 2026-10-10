import Foundation

public struct BuildComparisonUseCase: Sendable {
    enum Failure: Error, Equatable {
        case invalidSelection(count: Int)
    }

    private let propertyRepository: any PropertyRepository
    private let photoRepository: any PhotoRepository

    public init(propertyRepository: any PropertyRepository, photoRepository: any PhotoRepository) {
        self.propertyRepository = propertyRepository
        self.photoRepository = photoRepository
    }

    public func execute(propertyIDs: [UUID]) async throws -> [ComparisonEntry] {
        let allowedCount = Limits.comparisonMinimumCount...Limits.comparisonMaximumCount
        if !allowedCount.contains(propertyIDs.count) {
            throw Failure.invalidSelection(count: propertyIDs.count)
        }
        var entries: [ComparisonEntry] = []
        for propertyID in propertyIDs {
            guard let property = try await propertyRepository.fetch(id: propertyID) else {
                continue
            }
            let image = try await representativeImage(of: property)
            entries.append(ComparisonEntry(property: property, representativeImage: image))
        }
        return entries
    }

    // MARK: - Private

    private func representativeImage(of property: Property) async throws -> Data? {
        guard let photo = property.representativePhoto else {
            return nil
        }
        return try await photoRepository.imageData(id: photo.id)
    }
}
