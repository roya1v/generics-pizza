import SwiftUI

public struct CardView<Content>: View where Content: View {

    var content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
            .background(.white)
            .compositingGroup()
            .cornerRadius(16.0)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView {
            Text("Demo")
                .padding()
        }
        .padding()
        #if os(iOS)
        .background(Color(.systemGray6))
        #endif
    }
}
