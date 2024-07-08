//
//  NowView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 13/03/2023.
//

import SwiftUI
import GenericsCore
import ComposableArchitecture
import SharedModels

struct NowView: View {

    let store: StoreOf<NowFeature>

    var body: some View {
        WithPerceptionTracking {
            List {
                Section("Orders") {
                    ForEach(store.state.orders) { order in
                        OrderListRowView(order: order) {
                            store.send(.update(orderId: order.id!, state: order.state!.next()))
                        }
                        Divider()
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
    NowView(store: Store(initialState: NowFeature.State(orders: [], isLoading: false), reducer: {
        NowFeature()
    }))
}

extension OrderState {
    func next() -> Self {
        switch self {
        case .new:
                .inProgress
        case .inProgress:
                .readyForDelivery
        case .readyForDelivery:
                .inDelivery
        case .inDelivery:
                .finished
        case .finished:
            fatalError()
        }
    }
}
