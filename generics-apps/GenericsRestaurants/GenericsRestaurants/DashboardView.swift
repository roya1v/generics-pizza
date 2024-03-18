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
}

struct DashboardView: View {

    @State private var selected: Items = .now
    @Injected(\.authenticationRepository) private var repository

    var body: some View {
        NavigationSplitView {
            List(selection: $selected) {
                Section("Orders") {
                    NavigationLink("Current", value: Items.now)
                    NavigationLink("History", value: Items.orderHistory)
                }
                Section("Other") {
                    NavigationLink("Menu", value: Items.menu)
                }
            }
            Button {
                Task {
                    try? await repository.signOut()
                }
            } label: {
                Text("Sign out")
            }
            .padding()
        } detail: {
            switch selected {
            case .now:
                NowView()
            case .orderHistory:
                OrderHistoryView(store: Store(initialState: OrderHistoryFeature.State(items: [])) {
                    OrderHistoryFeature()
                })
            case .menu:
                MenuView()
            }
        }
    }
}

#Preview {
    DashboardView()
}
