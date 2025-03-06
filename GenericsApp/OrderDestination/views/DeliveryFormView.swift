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

    private enum Field {
        case street, floor, appartment, comment
    }

    @Bindable
    var store: StoreOf<DeliveryFormFeature>

    @FocusState
    private var fieldFocus: Field?

    var body: some View {
        WithPerceptionTracking {
            VStack {
                TextField("Street", text: $store.street)
                    .textFieldStyle(.roundedBorder)
                    .focused($fieldFocus, equals: .street)
                    .onSubmit { fieldFocus = .floor }
                HStack {
                    TextField("Floor", text: $store.floor)
                        .textFieldStyle(.roundedBorder)
                        .focused($fieldFocus, equals: .floor)
                        .onSubmit { fieldFocus = .appartment }
                    TextField("Appartment", text: $store.appartment)
                        .textFieldStyle(.roundedBorder)
                        .focused($fieldFocus, equals: .appartment)
                        .onSubmit { fieldFocus = .comment }
                }
                TextField("Comment", text: $store.comment)
                    .textFieldStyle(.roundedBorder)
                    .focused($fieldFocus, equals: .comment)
            }
        }
    }
}
