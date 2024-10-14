import SwiftUI
import ComposableArchitecture
import GenericsUI

struct PickUpFormView: View {

    @Perception.Bindable
    var store: StoreOf<OrderDestinationFeature>


    var body: some View {
        VStack {
            Text("Restaurant #1")
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
