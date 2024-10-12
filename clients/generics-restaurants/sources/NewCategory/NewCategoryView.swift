import SwiftUI
import ComposableArchitecture

struct NewCategoryView: View {

    @Perception.Bindable
    var store: StoreOf<NewCategoryFeature>

    var body: some View {
        VStack {
            TextField("Category name", text: $store.name.sending(\.nameUpdated))

            HStack {
                Button("Create") {
                    store.send(.createTapped)
                }
                Button("Cancel") {
                    store.send(.cancelTapped)
                }
            }
        }
        .padding()
    }
}
