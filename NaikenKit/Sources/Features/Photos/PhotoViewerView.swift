import DesignSystem
import SwiftUI
import UIKit

public struct PhotoViewerView: View {
    private static let minimumScale: CGFloat = 1
    private static let maximumScale: CGFloat = 4

    @State private var viewModel: PhotoViewerViewModel
    @State private var scale: CGFloat = 1
    @Environment(Router.self) private var router

    public init(viewModel: PhotoViewerViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("閉じる") { router.dismiss() }
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
        }
        .task { await viewModel.load() }
    }

    // MARK: - Private

    @ViewBuilder
    private var content: some View {
        if let data = viewModel.imageData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .gesture(magnification)
                .accessibilityLabel("写真")
        } else if viewModel.hasLoaded {
            ContentUnavailableView("写真を読み込めません", systemImage: "photo")
        } else {
            ProgressView()
        }
    }

    private var magnification: some Gesture {
        return MagnifyGesture()
            .onChanged { value in
                scale = min(max(value.magnification, Self.minimumScale), Self.maximumScale)
            }
            .onEnded { _ in
                withAnimation {
                    scale = Self.minimumScale
                }
            }
    }
}
