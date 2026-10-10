import ARKit
import SceneKit
import SwiftUI

/// RealityKit の ARView ではなく ARSCNView を使うのは、Platform が持つ ARSession をそのまま渡せて、特徴点も標準の表示で出せるため
struct ARCameraView: UIViewRepresentable {
    let session: ARSession

    func makeUIView(context _: Context) -> ARSCNView {
        let view = ARSCNView(frame: .zero)
        view.session = session
        view.automaticallyUpdatesLighting = true
        view.debugOptions = [.showFeaturePoints]
        return view
    }

    func updateUIView(_: ARSCNView, context _: Context) {}
}
