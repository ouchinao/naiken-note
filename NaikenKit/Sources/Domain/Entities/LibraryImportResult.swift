import Foundation

public struct LibraryImportResult: Sendable {
    public let importedIDs: [String]
    public let failedIDs: [String]
}
