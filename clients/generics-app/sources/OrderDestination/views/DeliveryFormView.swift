import SwiftUI
import ComposableArchitecture
import GenericsUI

struct DeliveryFormView: View {

    @Perception.Bindable
    var store: StoreOf<OrderDestinationFeature>

    var body: some View {
        VStack {
            TextField("Street", text: .constant(""))
            HStack {
                TextField("Floor", text: .constant(""))
                TextField("Appartment", text: .constant(""))
            }
            TextField("Comment", text: .constant(""))
            Button {
                store.send(.confirm)
            } label: {
                Text("Order here")
                    .frame(maxWidth: .infinity)
                    .frame(height: 32.0)
            }
            .buttonStyle(GPrimaryButtonStyle())

        }
    }
}
