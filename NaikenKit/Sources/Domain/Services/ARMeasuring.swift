import Foundation

/// raycast の結果や座標の型を受け渡さず、正規化した点とミリだけでやりとりするのは、Domain と ViewModel を ARKit に依存させないため
@MainActor
public protocol ARMeasuring: AnyObject {
    var isLiDARAvailable: Bool { get }
    var placedPointCount: Int { get }
    var distanceMillimeters: Int? { get }
    var onFailure: (@MainActor (ARMeasurement.Failure) -> Void)? { get set }
    func start()
    func pause()
    /// 画面のポイントではなく0〜1に正規化した座標で渡すのは、ARKit の displayTransform が正規化座標を前提にしているため
    func placePoint(normalizedX: Double, normalizedY: Double, viewportWidth: Double, viewportHeight: Double) -> Bool
    func reset()
}
