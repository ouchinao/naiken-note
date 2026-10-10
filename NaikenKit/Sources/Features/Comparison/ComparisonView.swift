import DesignSystem
import StoreKit
import SwiftUI
import UIKit

public struct ComparisonView: View {
    @State private var viewModel: ComparisonViewModel
    @State private var isSharing = false
    @Environment(Router.self) private var router
    @Environment(\.requestReview) private var requestReview

    public init(viewModel: ComparisonViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ComparisonTableView(entries: viewModel.entries, showsBranding: false)
        }
        .overlay {
            if viewModel.isLoading && viewModel.entries.isEmpty {
                ProgressView()
            }
        }
        .navigationTitle("比較表")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { shareBar }
        .task { await viewModel.load() }
        .onDisappear {
            // 起動時などではなくここで頼むのは、比較表を送った直後がいちばん満足している瞬間だから
            if viewModel.hasShared {
                requestReview()
            }
        }
        .alert(
            "確認",
            isPresented: $viewModel.isNoticePresented,
            presenting: viewModel.notice
        ) { notice in
            if case .locked = notice {
                Button("解除する") { router.present(.paywall) }
            }
            Button("閉じる", role: .cancel) {}
        } message: { notice in
            switch notice {
            case .locked:
                Text("比較表の画像出力は、機能を解除すると使えます")
            case .failed(let message):
                Text(message)
            }
        }
    }

    // MARK: - Private

    @ViewBuilder
    private var shareBar: some View {
        Group {
            if let data = viewModel.exportedImage, let image = UIImage(data: data) {
                Button {
                    isSharing = true
                } label: {
                    Label("画像を送る", systemImage: "square.and.arrow.up")
                }
                .sheet(isPresented: $isSharing) {
                    ActivityView(items: [image]) { completed in
                        if completed {
                            viewModel.recordShare()
                        }
                    }
                    .presentationDetents([.medium, .large])
                }
            } else {
                Button {
                    Task { await viewModel.export() }
                } label: {
                    Label("画像にする", systemImage: "photo")
                }
                .disabled(viewModel.entries.isEmpty || viewModel.isExporting)
            }
        }
        .buttonStyle(.primary)
        .padding()
        .background(.bar)
    }
}
