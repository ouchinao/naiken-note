import Domain
import Foundation

@MainActor
final class ARMeasuringStub: ARMeasuring {
    let isLiDARAvailable = false
    var onFailure: (@MainActor (ARMeasurement.Failure) -> Void)?
    private(set) var placedPointCount = 0
    private(set) var receivedPoints: [CGPoint] = []
    private(set) var resetCount = 0

    var distanceMillimeters: Int? {
        return placedPointCount == ARMeasurement.pointCount ? distance : nil
    }

    private let isSurfaceFound: Bool
    private let distance: Int

    init(isSurfaceFound: Bool = true, distance: Int = 1_000) {
        self.isSurfaceFound = isSurfaceFound
        self.distance = distance
    }

    func start() {}

    func pause() {}

    func placePoint(normalizedX: Double, normalizedY: Double, viewportWidth _: Double, viewportHeight _: Double) -> Bool {
        if !isSurfaceFound {
            return false
        }
        receivedPoints.append(CGPoint(x: normalizedX, y: normalizedY))
        placedPointCount += 1
        return true
    }

    func reset() {
        placedPointCount = 0
        resetCount += 1
    }

    func fail(with failure: ARMeasurement.Failure) {
        onFailure?(failure)
    }
}
