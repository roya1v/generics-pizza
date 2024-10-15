import SwiftUI
import ComposableArchitecture
import GenericsUI

@Reducer
struct DeliveryFormFeature {
    @ObservableState
    struct State: Equatable, Hashable {
        var street = ""
        var floor = ""
        var appartment = ""
        var comment = ""
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
    }
}

struct DeliveryFormView: View {

    @Perception.Bindable
    var store: StoreOf<DeliveryFormFeature>

    var body: some View {
        VStack {
            TextField("Street", text: $store.street)
            HStack {
                TextField("Floor", text: $store.floor)
                TextField("Appartment", text: $store.appartment)
            }
            TextField("Comment", text: $store.comment)
        }
    }
}
