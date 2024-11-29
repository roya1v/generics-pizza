import ComposableArchitecture
import AuthLogic

@Reducer
struct AppFeature {
    @ObservableState
    enum State: Equatable {
        case splash
        case auth(LoginFeature.State)
        case dashboard
    }

    enum Action {
        case auth(LoginFeature.Action)
        case dashboard
        case appLoaded(isLoggedIn: Bool)
        case appeared
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> {state, action in
            switch action {
            case .appeared:
                return .run { send in
                    try? await Task.sleep(for: .seconds(3))
                    await send(.appLoaded(isLoggedIn: false))
                }
            case .appLoaded(let isLoggedIn):
                if isLoggedIn {
                    state = .dashboard
                } else {
                    state = .auth(LoginFeature.State())
                }
                return .none
            case .auth(.loginCompleted(let error)):
                if let error {

                } else {
                    state = .dashboard
                }
                return .none
            case .auth:
                return .none
            case .dashboard:
                return .none
            }
        }
        .ifLet(\.auth, action: \.auth) {
            LoginFeature()
        }
    }
}
