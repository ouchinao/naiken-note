import Foundation

public enum ARMeasurement {
    public enum Failure: Sendable {
        case cameraDenied
        case sessionFailed
    }

    public static let pointCount = 2
}
