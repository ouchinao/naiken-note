import DesignSystem
import SwiftUI

public struct CameraScreen: View {
    private static let toastDuration: Duration = .seconds(1.5)

    @State private var viewModel: CameraCaptureViewModel
    @State private var captureCount = 0
    @State private var isShowingToast = false
    @Environment(Router.self) private var router

    public init(viewModel: CameraCaptureViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        content
            .overlay {
                if isShowingToast {
                    Text("保存しました（\(viewModel.savedCount)枚）")
                        .font(.headline)
                        .padding()
                        .background(.regularMaterial, in: Capsule())
                        .transition(.opacity)
                }
            }
            .task(id: captureCount) {
                if captureCount > 0 {
                    isShowingToast = true
                    try? await Task.sleep(for: Self.toastDuration)
                    withAnimation { isShowingToast = false }
                }
            }
            .alert("確認", isPresented: $viewModel.isNoticePresented, presenting: viewModel.notice) { _ in
                Button("閉じる", role: .cancel) {}
            } message: { notice in
                switch notice {
                case .failed(let message):
                    Text(message)
                }
            }
    }

    // MARK: - Private

    @ViewBuilder
    private var content: some View {
        if CameraView.isAvailable {
            // UIImagePickerController を使い回さないのは、1枚撮ると撮影の画面に戻らないため
            CameraView { data in
                captureCount += 1
                Task { await viewModel.save(data) }
            } onCancel: {
                router.dismiss()
            }
            .id(captureCount)
            .ignoresSafeArea()
        } else {
            NavigationStack {
                ContentUnavailableView(
                    "カメラを使えません",
                    systemImage: "camera",
                    description: Text("このデバイスではカメラを使えません。写真ライブラリから追加してください")
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("閉じる") { router.dismiss() }
                    }
                }
            }
        }
    }
}
