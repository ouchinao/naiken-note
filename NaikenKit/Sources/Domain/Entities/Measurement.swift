import Foundation

public struct Measurement: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var label: String
    public var valueMillimeters: Int
    public var note: String
    public var photoID: UUID?
    public let createdAt: Date

    public init(
        id: UUID,
        label: String,
        valueMillimeters: Int,
        note: String = "",
        photoID: UUID? = nil,
        createdAt: Date
    ) {
        self.id = id
        self.label = label
        self.valueMillimeters = valueMillimeters
        self.note = note
        self.photoID = photoID
        self.createdAt = createdAt
    }
}
