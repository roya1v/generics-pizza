import ComposableArchitecture
import Factory
import Foundation
import GenericsCore
import SharedModels
import GenericsHelpers

@Reducer
struct DashboardFeature {
    @ObservableState
    struct State: Equatable {
        var now: NowFeature.State
        var orderHistory: SimpleListState<OrderModel>
        var menu: MenuFeature.State
        var users: SimpleListState<UserModel>?
        var isLoggingOut = false
    }

    enum Action {
        case now(NowFeature.Action)
        case orderHistory(OrderHistoryFeature.Action)
        case menu(MenuFeature.Action)
        case users(UsersFeature.Action)
        case signOutTapped
        case signOutComplete(Result<Void, Error>)
    }

    @Injected(\.authenticationRepository)
    var repository

    var body: some ReducerOf<Self> {
        Scope(state: \.now, action: \.now) {
            NowFeature()
        }
        Scope(state: \.orderHistory, action: \.orderHistory) {
            OrderHistoryFeature()
        }
        Scope(state: \.menu, action: \.menu) {
            MenuFeature()
        }
        Reduce<State, Action> { state, action in
            switch action {
            case .now:
                return .none
            case .orderHistory:
                return .none
            case .menu:
                return .none
            case .users:
                return .none
            case .signOutTapped:
                state.isLoggingOut = true
                return .run { send in
                    await send(
                        .signOutComplete(
                            Result { try await repository.signOut() }
                        )
                    )
                }
            case .signOutComplete(.success):
                return .none
            case .signOutComplete(.failure(let error)):
                // TODO: Add error handling
                return .none
            }
        }
        .ifLet(\.users, action: \.users) {
            UsersFeature()
        }
    }
}
