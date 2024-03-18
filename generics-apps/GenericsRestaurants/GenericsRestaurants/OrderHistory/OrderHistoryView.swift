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
                        orderRow(for: order)
                        Divider()
                    }
                }
            }
            .onAppear {
                store.send(.shown)
            }
        }
    }

    @ViewBuilder
    func orderRow(for order: OrderModel) -> some View {
        VStack(alignment: .leading) {
            Text("ID: \(order.id!.uuidString)")
                .font(.caption)
            Text(order.createdAt!, style: .time)
                .font(.caption)
            let items = order.items.reduce("", {$0 + $1.title})
            Text("**Items:** \(items)")
        }
    }
}

#Preview {
    OrderHistoryView(store: Store(initialState: OrderHistoryFeature.State(items: [])) {
        OrderHistoryFeature()
    })
}
