import SwiftUI

public struct GPrimaryButtonStyle: ButtonStyle {

    public init() { }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.gNormal)
            .background(Color.gAccent)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

public struct GLinkButtonStyle: ButtonStyle {

    public enum Style: Equatable {
        case active, inactive
    }

    private let style: Style

    public init(style: Style = .active) {
        self.style = style
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.gNormal)
            .foregroundStyle(style == .active
                             ? Color.gAccent
                             : Color.gInactive)
    }
}
