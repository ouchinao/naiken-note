import SwiftUI
import UIKit

/// AVCaptureSession でカメラを作り込まないのは、まず標準のカメラで足りるかを確かめるため
struct CameraView: UIViewControllerRepresentable {
    /// `ImageSpec.jpegQuality` で書き出さないのは、保存の前にもう一度縮小して書き出すので、ここで品質を落とすと劣化が重なるため
    private static let originalQuality: CGFloat = 0.9

    let onCapture: (Data) -> Void
    let onCancel: () -> Void

    static var isAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(onCapture: onCapture, onCancel: onCancel)
    }

    @MainActor
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let onCapture: (Data) -> Void
        private let onCancel: () -> Void

        init(onCapture: @escaping (Data) -> Void, onCancel: @escaping () -> Void) {
            self.onCapture = onCapture
            self.onCancel = onCancel
        }

        func imagePickerController(
            _: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            guard let image = info[.originalImage] as? UIImage else {
                return
            }
            // 原寸の書き出しをメインスレッドでしないのは、続けて撮るときにカメラの画面へ戻るのが遅れるため。
            // UIImage は作ったあと書き換えないので、別のスレッドへ渡しても競合しない
            nonisolated(unsafe) let captured = image
            let quality = CameraView.originalQuality
            Task { [weak self] in
                let encoding = Task.detached(priority: .userInitiated) {
                    return captured.jpegData(compressionQuality: quality)
                }
                if let data = await encoding.value {
                    self?.onCapture(data)
                }
            }
        }

        func imagePickerControllerDidCancel(_: UIImagePickerController) {
            onCancel()
        }
    }
}
