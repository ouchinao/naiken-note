import Foundation

public protocol CheckResultRepository: Sendable {
    func save(_ result: CheckResult, propertyID: UUID) async throws
}
