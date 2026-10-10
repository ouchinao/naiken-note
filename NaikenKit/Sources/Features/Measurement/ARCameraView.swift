import ARKit
import SceneKit
import SwiftUI

/// ARSessionのカメラ映像と特徴点を表示する
struct ARCameraView: UIViewRepresentable {
    let session: ARSession

    func makeUIView(context: Context) -> ARSCNView {
        let view = ARSCNView(frame: .zero)
        view.session = session
        view.automaticallyUpdatesLighting = true
        view.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        return view
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}
}
