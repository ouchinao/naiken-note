import Foundation

public struct ComparisonEntry: Identifiable, Hashable, Sendable {
    public let property: Property
    public let representativeImage: Data?

    public var id: UUID {
        return property.id
    }

    init(property: Property, representativeImage: Data?) {
        self.property = property
        self.representativeImage = representativeImage
    }
}
