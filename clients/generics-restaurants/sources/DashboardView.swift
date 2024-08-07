//
//  DashboardView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 13/03/2023.
//

import SwiftUI
import Factory
import ComposableArchitecture

enum Items: String {
    case now
    case orderHistory
    case menu
    case users
}

struct DashboardView: View {

    @State private var selected: Items = .now
    let store: StoreOf<DashboardFeature>

    var body: some View {
        WithPerceptionTracking {
            NavigationSplitView {
                List(selection: $selected) {
                    Section("Orders") {
                        NavigationLink("Current", value: Items.now)
                        NavigationLink("History", value: Items.orderHistory)
                    }
                    Section("Other") {
                        NavigationLink("Menu", value: Items.menu)
                        NavigationLink("Users", value: Items.users)
                    }
                }
            } detail: {
                switch selected {
                case .now:
                    NowView(store: store.scope(state: \.now,
                                               action: \.now))
                case .orderHistory:
                    OrderHistoryView(store: store.scope(state: \.orderHistory,
                                                        action: \.orderHistory))
                case .menu:
                    MenuView(store: store.scope(state: \.menu,
                                                action: \.menu))
                case .users:
                    if let store = store.scope(state: \.users,
                                               action: \.users) {
                        UsersView(store: store)
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView(store: Store(
        initialState: DashboardFeature.State(now: NowFeature.State(),
                                             orderHistory: OrderHistoryFeature.State(),
                                             menu: MenuFeature.State())) {
                                                 DashboardFeature()
                                             }
    )
}
