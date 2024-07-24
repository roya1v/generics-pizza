//
//  MenuView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 13/03/2023.
//

import SwiftUI
import Factory
import clients_libraries_GenericsCore
import SharedModels
import ComposableArchitecture

struct MenuView: View {

    @Perception.Bindable var store: StoreOf<MenuFeature>

    var body: some View {
        WithPerceptionTracking {
            Group {
                switch store.menuState {
                case .loading:
                    ProgressView()
                case .loaded(let items):
                    List {
                        ForEach(items) { item in
                            listRow(for: item)
                        }
                    }
                    .listStyle(.inset(alternatesRowBackgrounds: true))
                case .error(let message):
                    Text(message)
                }
            }
            .onAppear {
                store.send(.shown)
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("New") {
                        store.send(.newItemButtonTapped)
                    }
                }
            }
            .navigationTitle("Menu")
            .confirmationDialog($store.scope(state: \.deleteConfirmationDialog, action: \.deleteConfirmationDialog))
            .sheet(item: $store.scope(state: \.newItem, action: \.newItem)) { newItemStore in
                NewMenuItemView(store: newItemStore)
            }
        }
    }

    func listRow(for item: MenuItem) -> some View {
        HStack {
            if let url = store.imageUrls[item.id] {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure, .empty:
                        Image("pizzza_placeholder")
                            .resizable()
                            .scaledToFit()
                    @unknown default:
                        fatalError()
                    }
                }
                .frame(width: 75.0)
            }
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.title2)
                Text(item.description)
                    .font(.caption)
            }
            Spacer()
            Text(item.formattedPrice())
                .bold()
                .padding()
            Button {

            } label: {
                Text("Edit")
                    .underline()
            }
            .buttonStyle(.link)
            .padding()
        }
        .contextMenu {
            Button {
                store.send(.delete(item))
            } label: {
                Text("Delete item")
            }
        }
    }
}

#Preview {
    MenuView(
        store: Store(
            initialState: MenuFeature.State()) {
                MenuFeature()
            }
    )
}
