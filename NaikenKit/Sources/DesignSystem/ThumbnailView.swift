import SwiftUI
import UIKit

/// 画像データを正方形に切り抜いて表示する。データがなければプレースホルダを出す。
/// `size` を省略すると、親から与えられた大きさいっぱいに広がる
public struct ThumbnailView: View {
    private let data: Data?
    private let size: CGFloat?

    public init(data: Data?, size: CGFloat? = nil) {
        self.data = data
        self.size = size
    }

    public var body: some View {
        Group {
            if let data, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.surface)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
    }
}
