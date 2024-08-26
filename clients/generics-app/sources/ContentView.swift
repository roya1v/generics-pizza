//
//  ContentView.swift
//  GenericsApp
//
//  Created by Mike S. on 01/02/2023.
//

import SwiftUI
import clients_libraries_GenericsUI
import ComposableArchitecture

struct ContentView: View {

    @Perception.Bindable var store: StoreOf<AppFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottomTrailing) {
                MenuView(
                    store: store.scope(
                        state: \.menu,
                        action: \.menu
                    )
                )
                
                if !store.cart.isEmpty {
                    Button {
                        store.send(.showMenu)
                    } label: {
                        HStack {
                            Text("Cart")
                            Image(systemName: "cart")
                        }
                        .padding(.gNormal)
                    }
                    .buttonStyle(GPrimaryButtonStyle())
                    .padding()
                }
            }
            .task {
                store.send(.launched)
            }
            .sheet(item: $store.scope(
                state: \.cartState,
                action: \.cart
            )
            ) { store in
                CartView(store: store)
            }
        }
    }
}
