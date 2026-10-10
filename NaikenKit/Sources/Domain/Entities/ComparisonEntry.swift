import Foundation

/// 比較表の1列(1物件)
public struct ComparisonEntry: Identifiable, Hashable, Sendable {
    public let property: Property
    /// 代表写真の画像データ。写真がなければnil
    public let representativeImage: Data?

    public var id: UUID {
        return property.id
    }

    public init(property: Property, representativeImage: Data?) {
        self.property = property
        self.representativeImage = representativeImage
    }
}
