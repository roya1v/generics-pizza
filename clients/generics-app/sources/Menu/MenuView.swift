//
//  MenuView.swift
//  GenericsApp
//
//  Created by Mike S. on 01/02/2023.
//

import SwiftUI
import Factory
import SharedModels
import clients_libraries_GenericsCore
import ComposableArchitecture

struct MenuView: View {

    @Perception.Bindable var store: StoreOf<MenuFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack {
                RoundedRectangle(cornerRadius: .gBig)
                    .fill(Color.white)
                    .ignoresSafeArea()

                VStack {
                    MenuHeaderView()
                    switch store.content {
                    case .loading:
                        ProgressView()
                    case .error(let error):
                        Text(error)
                    case .loaded:
                        menu(state: store.state)
                    }
                }
            }

            .fullScreenCover(
                item: $store.scope(
                    state: \.menuDetail,
                    action: \.menuDetail
                )
            ) { item in
                NavigationView { // So we see the nav title
                    MenuDetailView(store: item)
                }
            }
            .task {
                store.send(.appeared)
            }
        }
    }

    func menu(state: MenuFeature.State) -> some View {
        WithPerceptionTracking {
            if let items = store.content.items {
                List(items) { item in
                    MenuRowView(
                        item: item
                    ) {
                        store.send(.didSelect(item.id!))
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }

        }
    }
}
