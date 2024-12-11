import ComposableArchitecture
import AuthLogic
import GenericsCore
import Factory

@Reducer
struct AppFeature {
    @ObservableState
    enum State: Equatable {
        case splash
        case auth(LoginFeature.State)
        case dashboard(DashboardFeature.State)
    }

    enum Action {
        case auth(LoginFeature.Action)
        case dashboard(DashboardFeature.Action)
        case appLoaded(isLoggedIn: Bool)
        case appeared
    }

    @Injected(\.authenticationRepository)
    private var repository

    var body: some ReducerOf<Self> {
        Reduce<State, Action> {state, action in
            switch action {
            case .appeared:
                state = .splash
                return .run { send in
                    let currentUser = await repository.checkState()
                    await send(.appLoaded(isLoggedIn: currentUser != nil))
                }
            case .appLoaded(let isLoggedIn):
                if isLoggedIn {
                    state = .dashboard(DashboardFeature.State())
                } else {
                    state = .auth(LoginFeature.State())
                }
                return .none
            case .auth(.loginCompleted(.none)):
                state = .dashboard(DashboardFeature.State())
                return .none
            case .dashboard(.profile(.presented(.loggedOut(.success)))):
                state = .auth(LoginFeature.State())
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
        .ifLet(\.dashboard, action: \.dashboard) {
            DashboardFeature()
        }
    }
}
