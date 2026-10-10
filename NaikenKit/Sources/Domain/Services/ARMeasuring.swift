import Foundation

/// AR採寸のセッション。ARKitの型は外に出さず、画面上の点とミリ単位の距離だけでやりとりする
@MainActor
public protocol ARMeasuring: AnyObject {
    /// LiDAR搭載機ならtrue。非搭載機では精度が落ちる
    var isLiDARAvailable: Bool { get }
    /// 置いた測定点の数(0〜2)
    var placedPointCount: Int { get }
    /// 2点置いていれば、その間の距離(ミリ)
    var distanceMillimeters: Int? { get }
    func start()
    func pause()
    /// 画面上の点に測定点を置く。座標はビューの左上を原点に0〜1で正規化する。面が見つからなければfalse
    func placePoint(normalizedX: Double, normalizedY: Double, viewportWidth: Double, viewportHeight: Double) -> Bool
    func reset()
}
