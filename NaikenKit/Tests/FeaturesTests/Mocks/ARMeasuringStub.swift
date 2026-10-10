import Domain
import Foundation

/// 面が見つかるかどうかと2点間の距離を決め打ちで返す
@MainActor
final class ARMeasuringStub: ARMeasuring {
    let isLiDARAvailable = false
    private(set) var placedPointCount = 0
    /// 受け取った正規化済みの座標
    private(set) var receivedPoints: [CGPoint] = []

    var distanceMillimeters: Int? {
        return placedPointCount == 2 ? distance : nil
    }

    private let isSurfaceFound: Bool
    private let distance: Int

    init(isSurfaceFound: Bool = true, distance: Int = 1_000) {
        self.isSurfaceFound = isSurfaceFound
        self.distance = distance
    }

    func start() {}

    func pause() {}

    func placePoint(normalizedX: Double, normalizedY: Double, viewportWidth: Double, viewportHeight: Double) -> Bool {
        if !isSurfaceFound {
            return false
        }
        receivedPoints.append(CGPoint(x: normalizedX, y: normalizedY))
        placedPointCount = placedPointCount == 2 ? 1 : placedPointCount + 1
        return true
    }

    func reset() {
        placedPointCount = 0
    }
}
