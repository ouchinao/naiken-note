import Foundation

public struct Measurement: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let label: String
    public let valueMillimeters: Int
    public let note: String
    public let photoID: UUID?
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
