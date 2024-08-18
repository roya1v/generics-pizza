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

    @State var isShowingMenu = false
    var store: StoreOf<AppFeature> = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MenuView(
                store: store.scope(
                    state: \.menu,
                    action: \.menu
                )
            )
            WithPerceptionTracking {
                if !store.cart.isEmpty {
                    Button {
                        isShowingMenu = true
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

        }
        .task {
            store.send(.launched)
        }
        .sheet(isPresented: $isShowingMenu) {
            CartView()
        }
    }
}

#Preview {
    ContentView()
}
