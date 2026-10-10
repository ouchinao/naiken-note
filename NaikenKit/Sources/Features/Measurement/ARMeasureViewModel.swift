import Domain
import Foundation
import Observation

/// AR採寸の画面の状態。受け取るのはミリ単位の距離だけで、ARKitの型は扱わない
@MainActor
@Observable
public final class ARMeasureViewModel {
    // MARK: - State

    /// 画面上でタップした位置。2点まで
    private(set) var markers: [CGPoint] = []
    private(set) var distanceMillimeters: Int?
    private(set) var isSurfaceMissing = false

    var isLiDARAvailable: Bool {
        return measuring.isLiDARAvailable
    }

    var placedPointCount: Int {
        return markers.count
    }

    // MARK: - Init

    private let measuring: any ARMeasuring

    public init(measuring: any ARMeasuring) {
        self.measuring = measuring
    }

    // MARK: - Actions

    func start() {
        measuring.start()
    }

    func stop() {
        measuring.pause()
    }

    /// 画面をタップした位置に測定点を置く。3点目を置くと最初からやり直しになる
    func placePoint(at point: CGPoint, in size: CGSize) {
        if size.width <= 0 || size.height <= 0 {
            return
        }
        let isPlaced = measuring.placePoint(
            normalizedX: point.x / size.width,
            normalizedY: point.y / size.height,
            viewportWidth: size.width,
            viewportHeight: size.height
        )
        isSurfaceMissing = !isPlaced
        if !isPlaced {
            return
        }
        if measuring.placedPointCount == 1 {
            markers = [point]
        } else {
            markers.append(point)
        }
        distanceMillimeters = measuring.distanceMillimeters
    }

    func reset() {
        measuring.reset()
        markers = []
        distanceMillimeters = nil
        isSurfaceMissing = false
    }
}
