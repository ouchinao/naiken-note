import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class ARMeasureViewModel {
    // MARK: - State

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
