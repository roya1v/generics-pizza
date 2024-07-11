//
//  ContentView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 14/02/2023.
//

import SwiftUI
import Combine
import Factory
import clients_libraries_GenericsCore
import ComposableArchitecture

struct ContentView: View {
    
    var store: StoreOf<AppFeature> = Store(initialState: AppFeature.State.loading) {
        AppFeature()
    }

    var body: some View {
        WithPerceptionTracking {
            Group {
                switch store.state {
                case .loading:
                    Text("")
                case .login:
                    if let store = store.scope(
                        state: \.login,
                        action: \.login) {
                        LoginView(store: store)
                    }
                case .dashboard:
                    if let store = store.scope(
                        state: \.dashboard,
                        action: \.dashboard) {
                        DashboardView(store: store)
                    }
                    
                }
            }
            .task {
                store.send(.launched)
            }
        }
    }
}

#Preview {
    ContentView()
}
