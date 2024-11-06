import Foundation
import ComposableArchitecture
import Factory

@Reducer
struct LoginFeature {
    @ObservableState
    struct State: Equatable {
        var isLoading = false
        var errorMessage: String?
        var email = ""
        var password = ""
    }

    enum Action: BindableAction {
        case loginTapped
        case loginCompleted(Result<Void, Error>)
        case binding(BindingAction<State>)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce<State, Action> { state, action in
            switch action {
            case .loginTapped:
                state.isLoading = true
                return .run { send in
                    try? await Task.sleep(for: .seconds(2))
                    await send(.loginCompleted(.success(())))
                }
            case .loginCompleted(.failure(let error)):
                return .none
            case .loginCompleted:
                return .none
            case .binding:
                return .none
            }
        }
    }
}
