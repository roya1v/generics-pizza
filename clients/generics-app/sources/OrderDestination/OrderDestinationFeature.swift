import Combine
import ComposableArchitecture
import Factory
import Foundation
import GenericsCore
import SharedModels

@Reducer
struct OrderDestinationFeature {
    @ObservableState
    struct State: Equatable {
        enum Destination: String, Hashable {
            case delivery
            case restaurant
        }
        var destination = Destination.restaurant
    }

    enum Action: BindableAction {
        case appeared
        case dismissTapped
        case confirm
        case binding(BindingAction<State>)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
    }
}
