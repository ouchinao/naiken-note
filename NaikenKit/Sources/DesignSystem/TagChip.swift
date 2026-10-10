import SwiftUI

public struct TagChip: View {
    private let title: String
    private let isSelected: Bool

    public init(title: String, isSelected: Bool = false) {
        self.title = title
        self.isSelected = isSelected
    }

    public var body: some View {
        Text(title)
            .font(.caption)
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, Spacing.xSmall)
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .background(isSelected ? Color.brand : Color.surface, in: Capsule())
    }
}
