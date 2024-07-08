//
//  MenuView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 13/03/2023.
//

import SwiftUI
import Factory
import GenericsCore
import SharedModels
import ComposableArchitecture

struct MenuView: View {

    let store: StoreOf<MenuFeature>

    @Environment(\.openWindow) var openWindow

    @State var itemToDelete: MenuItem?
    @State var isDeleting = false
    @State var isCreating = false

    var body: some View {
        WithPerceptionTracking {
            VStack {
                if store.isLoading {
                    ProgressView()
                } else {
                    table
                }
            }
            .onAppear {
                store.send(.shown)
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("New") {
                        isCreating = true
                    }
                }
            }
            .navigationTitle("Menu")
            .sheet(isPresented: $isCreating,
                   onDismiss: {
                isCreating = false
                store.send(.shown)
            },
                   content: {
                NewMenuItemView(store: Store(initialState: NewMenuItemFeature.State(), reducer: {
                    NewMenuItemFeature()
                }))
            })
            .alert("Are you sure you want to delete \(itemToDelete?.title ?? "this item")?",
                   isPresented: $isDeleting,
                   presenting: itemToDelete) { item in
                Button(role: .destructive) {
                    store.send(.delete(item.id!))
                } label: {
                    Text("Delete")
                }
            }
        }
    }

    var table: some View {
        List {
            ForEach(store.items) { item in
                listRow(for: item)
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
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
                    case .failure(_), .empty:
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
        .contextMenu(menuItems: {
            Button {
                isDeleting = true
                itemToDelete = item
            } label: {
                Text("Delete item")
            }
        })
    }
}

#Preview {
    MenuView(store: Store(initialState: MenuFeature.State(items: [], isLoading: false, imageUrls: [:])){
        MenuFeature()
    })
}
