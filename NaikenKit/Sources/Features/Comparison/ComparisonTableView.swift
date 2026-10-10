import DesignSystem
import Domain
import SwiftUI

/// 書き出し用に別の View を作らないのは、画面で見た表と送った画像の中身がずれないようにするため
struct ComparisonTableView: View {
    private static let labelWidth: CGFloat = 80
    private static let columnWidth: CGFloat = 150
    private static let photoHeight: CGFloat = 110

    private let entries: [ComparisonEntry]
    private let showsBranding: Bool

    init(entries: [ComparisonEntry], showsBranding: Bool) {
        self.entries = entries
        self.showsBranding = showsBranding
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: Spacing.small) {
            Grid(alignment: .leading, horizontalSpacing: Spacing.medium, verticalSpacing: Spacing.small) {
                GridRow {
                    Color.clear
                        .frame(width: Self.labelWidth, height: 1)
                    ForEach(entries) { entry in
                        Text(entry.property.name)
                            .font(.headline)
                            .lineLimit(2)
                            .frame(width: Self.columnWidth, alignment: .leading)
                    }
                }
                Divider()
                row("写真") { entry in
                    Color.clear
                        .frame(width: Self.columnWidth, height: Self.photoHeight)
                        .overlay {
                            ThumbnailView(data: entry.representativeImage)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                }
                row("家賃") { Text(DisplayFormat.rent($0.property.rent)) }
                row("間取り") { Text(DisplayFormat.layout($0.property.layout)) }
                row("面積") { Text(DisplayFormat.area($0.property.areaSquareMeters)) }
                row("駅徒歩") { entry in
                    Text(DisplayFormat.access(station: entry.property.nearestStation, walkMinutes: entry.property.walkMinutes))
                }
                row("○の数") { entry in
                    Text("\(entry.property.goodCount) / \(CheckItemCatalog.all.count)")
                        .foregroundStyle(Color.positive)
                        .bold()
                }
            }
            if showsBranding {
                Text("内見ノートで作成")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: - Private

    private func row<Content: View>(
        _ title: LocalizedStringKey,
        @ViewBuilder content: @escaping (ComparisonEntry) -> Content
    ) -> some View {
        return GridRow {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: Self.labelWidth, alignment: .leading)
            ForEach(entries) { entry in
                content(entry)
                    .frame(width: Self.columnWidth, alignment: .leading)
            }
        }
    }
}
