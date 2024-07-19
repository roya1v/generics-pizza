//
//  DashboardFeature.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 11/07/2024.
//

import Foundation
import ComposableArchitecture
import Factory
import clients_libraries_GenericsCore

@Reducer
struct DashboardFeature {
    @ObservableState
    struct State: Equatable {
        var now: NowFeature.State
        var orderHistory: OrderHistoryFeature.State
        var menu: MenuFeature.State
        var users: UsersFeature.State?
    }

    enum Action {
        case now(NowFeature.Action)
        case orderHistory(OrderHistoryFeature.Action)
        case menu(MenuFeature.Action)
        case users(UsersFeature.Action)
    }

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
        Reduce { _, action in
            switch action {
            case .now:
                return .none
            case .orderHistory:
                return .none
            case .menu:
                return .none
            case .users:
                return .none
            }
        }
        .ifLet(\.users, action: \.users) {
            UsersFeature()
        }
    }
}
