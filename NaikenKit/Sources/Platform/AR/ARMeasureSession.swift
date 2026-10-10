import ARKit
import Domain
import Foundation

@MainActor
public final class ARMeasureSession: ARMeasuring {
    private static let millimetersPerMeter = 1_000.0

    public static var isSupported: Bool {
        return ARWorldTrackingConfiguration.isSupported
    }

    // MARK: - State

    /// ARMeasuring の外に ARSession を出しているのは、ARSCNView がカメラ映像を描くのに ARSession そのものが要るため
    public let session = ARSession()
    private let failureForwarder = FailureForwarder()
    private var points: [SIMD3<Float>] = []

    public var onFailure: (@MainActor (ARMeasurement.Failure) -> Void)? {
        get {
            return failureForwarder.onFailure
        }
        set {
            failureForwarder.onFailure = newValue
        }
    }

    public var isLiDARAvailable: Bool {
        return ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
    }

    public var placedPointCount: Int {
        return points.count
    }

    public var distanceMillimeters: Int? {
        if points.count < ARMeasurement.pointCount {
            return nil
        }
        let meters = Double(simd_distance(points[0], points[1]))
        return Int((meters * Self.millimetersPerMeter).rounded())
    }

    // MARK: - Init

    public init() {
        session.delegate = failureForwarder
    }

    // MARK: - Actions

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
        let position = result.worldTransform.columns.3
        points.append(SIMD3(position.x, position.y, position.z))
        return true
    }

    public func reset() {
        points.removeAll()
    }
}

/// 失敗を受け取らないままにしないのは、カメラの許可がないと面が見つからない案内だけが出続け、原因が分からないため
private final class FailureForwarder: NSObject, ARSessionDelegate {
    var onFailure: (@MainActor (ARMeasurement.Failure) -> Void)?

    func session(_: ARSession, didFailWithError error: any Error) {
        let failure: ARMeasurement.Failure
        if let arError = error as? ARError, arError.code == .cameraUnauthorized {
            failure = .cameraDenied
        } else {
            failure = .sessionFailed
        }
        let onFailure = onFailure
        // Task でメインアクターへ移さないのは、delegateQueue を指定しない ARSession はメインスレッドで呼ぶため
        MainActor.assumeIsolated {
            onFailure?(failure)
        }
    }
}
