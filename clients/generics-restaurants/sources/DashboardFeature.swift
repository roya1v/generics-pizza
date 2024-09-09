import Foundation
import ComposableArchitecture
import Factory
import clients_libraries_GenericsCore
import SharedModels

@Reducer
struct DashboardFeature {
    @ObservableState
    struct State: Equatable {
        var now: NowFeature.State
        var orderHistory: SimpleListState<OrderModel>
        var menu: MenuFeature.State
        var users: SimpleListState<UserModel>?
    }

    enum Action {
        case now(NowFeature.Action)
        case orderHistory(OrderHistoryFeature.Action)
        case menu(MenuFeature.Action)
        case users(UsersFeature.Action)
        case signOutTapped
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
        Reduce<State, Action> { _, action in
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
                return .run { _ in
                    // TODO: Add loading and error handling
                    try await repository.signOut()
                }
            }
        }
        .ifLet(\.users, action: \.users) {
            UsersFeature()
        }
    }
}
