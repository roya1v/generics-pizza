import ComposableArchitecture
import AuthLogic
import GenericsCore
import Factory

@Reducer
struct AppFeature {
    @ObservableState
    enum State: Equatable {
        case splash
        case welcome(WelcomeFeature.State)
        case dashboard(DashboardFeature.State)
    }

    enum Action {
        case welcome(WelcomeFeature.Action)
        case dashboard(DashboardFeature.Action)
        case appLoaded(isLoggedIn: Bool)
        case appeared
    }

    @Injected(\.authenticationRepository)
    private var repository

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
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
                    state = .welcome(.auth(LoginFeature.State()))
                }
                return .none
            case .welcome(.permissions(.authorizationChanged(.authorizedWhenInUse))):
                state = .dashboard(DashboardFeature.State())
                return .none
            case .dashboard(.profile(.presented(.loggedOut(.success)))):
                state = .welcome(.auth(LoginFeature.State()))
                return .none
            case .welcome:
                return .none
            case .dashboard:
                return .none
            }
        }
        .ifLet(\.welcome, action: \.welcome) {
            WelcomeFeature()
        }
        .ifLet(\.dashboard, action: \.dashboard) {
            DashboardFeature()
        }
    }
}
