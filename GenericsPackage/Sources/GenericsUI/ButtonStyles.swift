import SwiftUI

public struct GPrimaryButtonStyle: ButtonStyle {

    private let isWide: Bool

    public init(isWide: Bool = false) {
        self.isWide = isWide
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: isWide ? .infinity : nil)
            .padding(.gM)
            .background(Color.gAccent)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

public struct GPrimaryPillButtonStyle: ButtonStyle {

    public init() { }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.gXS)
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
            .padding(.gS)
            .foregroundStyle(style == .active
                             ? Color.gAccent
                             : Color.gInactive)
    }
}

#Preview {
    VStack {
        Button("Hello, World!") {

        }
        .buttonStyle(GPrimaryButtonStyle())
    }
    .padding()
}
