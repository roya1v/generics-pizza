import ComposableArchitecture
import Factory
import Foundation
import GenericsCore
import AuthLogic

@Reducer
struct AppFeature {
    @ObservableState
    enum State: Equatable {
        case loading
        case auth(AuthFeature.State)
        case dashboard(DashboardFeature.State)
    }

    enum Action {
        case launched
        case stateUpdated(isSignedIn: Bool)
        case auth(AuthFeature.Action)
        case dashboard(DashboardFeature.Action)
    }

    @Injected(\.authenticationRepository)
    var repository

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .launched:
                state = .loading
                return .run { send in
                    let currentUser = await repository.checkState()
                    await send(.stateUpdated(isSignedIn: currentUser != nil))
                }
            case .stateUpdated(let isSignedIn):
                if isSignedIn {
                    state = .dashboard(
                        DashboardFeature.State(
                            now: NowFeature.State(),
                            orderHistory: OrderHistoryFeature.State(),
                            insights: InsightsFeature.State(),
                            menu: MenuFeature.State(),
                            users: UsersFeature.State()
                        )
                    )
                } else {
                    state = .auth(.login(LoginFeature.State()))
                }
                return .none
            case .dashboard(.signOutComplete(.success)):
                state = .auth(.login(LoginFeature.State()))
                return .none
            case .auth(.login(.loginCompleted(.none))),
                .auth(.createAccount(.createAccountCompleted(.none))):
                state = .dashboard(
                    DashboardFeature.State(
                        now: NowFeature.State(),
                        orderHistory: OrderHistoryFeature.State(),
                        insights: InsightsFeature.State(),
                        menu: MenuFeature.State(),
                        users: UsersFeature.State()
                    )
                )
                return .none
            case .auth:
                return .none
            case .dashboard:
                return .none
            }
        }
        .ifCaseLet(\.auth, action: \.auth) {
            AuthFeature()
        }
        .ifCaseLet(\.dashboard, action: \.dashboard) {
            DashboardFeature()
        }
    }
}
