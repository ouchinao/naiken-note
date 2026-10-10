import Foundation

public protocol EntitlementProvider: Sendable {
    var current: Entitlement { get async }
}
