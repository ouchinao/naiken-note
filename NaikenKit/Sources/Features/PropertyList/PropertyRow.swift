import DesignSystem
import Domain
import SwiftUI

struct PropertyRow: View {
    private static let thumbnailSize: CGFloat = 56

    let property: Property
    let thumbnail: Data?
    let customerName: String?
    let isSelected: Bool?

    var body: some View {
        HStack(spacing: Spacing.medium) {
            if let isSelected {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.brand : Color.secondary)
            }
            ThumbnailView(data: thumbnail, size: Self.thumbnailSize)
            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                Text(property.name)
                    .font(.headline)
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(DisplayFormat.visitDate(property.visitedAt))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            if let customerName {
                TagChip(title: customerName)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    private var summary: String {
        return [
            DisplayFormat.rent(property.rent),
            DisplayFormat.layout(property.layout),
            DisplayFormat.access(station: property.nearestStation, walkMinutes: property.walkMinutes),
        ].joined(separator: " / ")
    }
}
