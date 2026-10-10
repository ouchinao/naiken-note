import ARKit
import Domain
import Foundation

/// ARSessionの開始・raycast・2点間の距離計算を担う。画面の表示はFeatures層の ARMeasureView が受け持つ
@MainActor
public final class ARMeasureSession: ARMeasuring {
    private static let millimetersPerMeter = 1_000.0
    private static let maximumPointCount = 2

    public static var isSupported: Bool {
        return ARWorldTrackingConfiguration.isSupported
    }

    /// ARMeasureView がカメラ映像を描くために使う
    public let session = ARSession()

    public var isLiDARAvailable: Bool {
        return ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
    }

    public var placedPointCount: Int {
        return points.count
    }

    public var distanceMillimeters: Int? {
        if points.count < Self.maximumPointCount {
            return nil
        }
        let meters = Double(simd_distance(points[0], points[1]))
        return Int((meters * Self.millimetersPerMeter).rounded())
    }

    private var points: [SIMD3<Float>] = []

    public init() {}

    public func start() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics.insert(.sceneDepth)
        }
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    public func pause() {
        session.pause()
    }

    public func placePoint(normalizedX: Double, normalizedY: Double, viewportWidth: Double, viewportHeight: Double) -> Bool {
        guard let frame = session.currentFrame else {
            return false
        }
        let viewportSize = CGSize(width: viewportWidth, height: viewportHeight)
        let toImage = frame.displayTransform(for: .portrait, viewportSize: viewportSize).inverted()
        let imagePoint = CGPoint(x: normalizedX, y: normalizedY).applying(toImage)
        let query = frame.raycastQuery(from: imagePoint, allowing: .estimatedPlane, alignment: .any)
        guard let result = session.raycast(query).first else {
            return false
        }
        if points.count >= Self.maximumPointCount {
            points.removeAll()
        }
        let position = result.worldTransform.columns.3
        points.append(SIMD3(position.x, position.y, position.z))
        return true
    }

    public func reset() {
        points.removeAll()
    }
}
