//
//  OrderHistoryView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 18/03/2024.
//

import SwiftUI
import ComposableArchitecture
import SharedModels

struct OrderHistoryView: View {

    let store: StoreOf<OrderHistoryFeature>

    var body: some View {
        WithPerceptionTracking {
            List {
                Section("Orders") {
                    ForEach(store.items) { order in
                        OrderListRowView(order: order, onTap: nil)
                    }
                }
            }
            .onAppear {
                store.send(.shown)
            }
        }
    }
}

#Preview {
    OrderHistoryView(store: Store(initialState: OrderHistoryFeature.State(items: [])) {
        OrderHistoryFeature()
    })
}
