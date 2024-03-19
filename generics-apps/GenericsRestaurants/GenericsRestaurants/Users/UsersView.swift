//
//  UsersView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 19/03/2024.
//

import SwiftUI
import ComposableArchitecture

struct UsersView: View {
    
    let store: StoreOf<UsersFeature>

    var body: some View {
        WithPerceptionTracking {
            Table(store.users) {
                TableColumn("Email", value: \.email)
            }
            .onAppear {
                store.send(.shown)
            }
        }
    }
}

#Preview {
    UsersView(store: Store(initialState: UsersFeature.State(isLoading: false, users: [])) {
        UsersFeature()
    })
}
