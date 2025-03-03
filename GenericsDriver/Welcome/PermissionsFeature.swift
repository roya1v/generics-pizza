import ComposableArchitecture
import AuthLogic
import GenericsCore
import Factory

@Reducer
struct PermissionsFeature {
    @ObservableState
    struct State: Equatable {

    }

    enum Action {
        // View
        case appeared
        case grantTapped
        // Child
        // Internal
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .appeared:
                return .none
            case .grantTapped:
                return .none
            }
        }
    }
}
