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
        NavigationView {
            ZStack {
                Color.gLight
                    .ignoresSafeArea()
                VStack {
                    MainHeaderView()
                        .padding()
                    ZStack {
                        RoundedRectangle(cornerRadius: .gBig)
                            .fill(Color.white)
                            .ignoresSafeArea()
                        WithPerceptionTracking {
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
        guard case let .loaded(items) = state.content else {
            fatalError()
        }
        return List(items) { item in
            MenuRowView(
                item: item,
                imageUrl: item.id != nil
                ? state.imageUrls[item.id!]
                : nil
            ) {
                store.send(.didSelect(item))
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
}
