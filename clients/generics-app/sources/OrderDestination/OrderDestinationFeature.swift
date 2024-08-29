import Foundation
import ComposableArchitecture
import Factory
import SharedModels
import clients_libraries_GenericsCore
import Combine

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
        Reduce<State, Action> { state, action in
            switch action {
            case .appeared:
                return .none
            case .dismissTapped:
                return .none
            case .confirm:
                return .none
            case .binding:
                return .none
            }
        }
    }
}
