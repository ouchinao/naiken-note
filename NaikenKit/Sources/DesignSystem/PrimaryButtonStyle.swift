import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
    private static let pressedOpacity = 0.7
    private static let disabledOpacity = 0.4

    @Environment(\.isEnabled) private var isEnabled

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.medium)
            .foregroundStyle(.white)
            .background(Color.brand, in: RoundedRectangle(cornerRadius: CornerRadius.medium))
            .opacity(opacity(isPressed: configuration.isPressed))
    }

    // MARK: - Private

    private func opacity(isPressed: Bool) -> Double {
        if !isEnabled {
            return Self.disabledOpacity
        }
        return isPressed ? Self.pressedOpacity : 1
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    public static var primary: PrimaryButtonStyle {
        return PrimaryButtonStyle()
    }
}
