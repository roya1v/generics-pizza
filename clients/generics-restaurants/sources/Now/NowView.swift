//
//  NowView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 13/03/2023.
//

import SwiftUI
import clients_libraries_GenericsCore
import ComposableArchitecture
import SharedModels

struct NowView: View {

    let store: StoreOf<NowFeature>

    var body: some View {
        WithPerceptionTracking {
            Group {
                switch store.connectionState {
                case .connecting:
                    ProgressView()
                case .failure(let message):
                    Text(message)
                case .success:
                    List {
                        Section("Orders") {
                            ForEach(store.state.orders) { order in
                                OrderListRowView(order: order) {
                                    store.send(.update(orderId: order.id!, state: order.state!.next()))
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                store.send(.shown)
            }
        }
    }
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
