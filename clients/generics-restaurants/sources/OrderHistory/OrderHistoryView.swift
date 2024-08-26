//
//  OrderHistoryView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 18/03/2024.
//

import SwiftUI
import ComposableArchitecture
import SharedModels
import clients_libraries_GenericsCore

struct OrderHistoryView: View {

    let store: StoreOf<OrderHistoryFeature>

    var body: some View {
        WithPerceptionTracking {
            Group {
                switch store.state {
                case .loading:
                    Text("Hello")
                case .loaded(let items):
                    List {
                        Section("Orders") {
                            ForEach(items) { order in
                                OrderListRowView(order: order, onTap: nil)
                            }
                        }
                    }
                case .error(let message):
                    Text(message)
                }
            }
            .onAppear {
                store.send(.shown)
            }
        }
    }
}
