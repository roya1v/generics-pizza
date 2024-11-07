import SwiftUI

public struct GPrimary: TextFieldStyle {

    public init() { }

    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.gNormal)
            .background {
                RoundedRectangle(cornerRadius: .gNormal, style: .continuous)
                    .fill(.regularMaterial)
            }
    }
}