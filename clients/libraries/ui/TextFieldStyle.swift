import SwiftUI

public struct GPrimary: TextFieldStyle {

    public init() { }

    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.gM)
            .background {
                RoundedRectangle(cornerRadius: .gM, style: .continuous)
                    .fill(.regularMaterial)
            }
    }
}
