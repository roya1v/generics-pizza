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

struct MenuView: View {
    @StateObject var model = MenuViewModel()

    @Environment(\.openWindow) var openWindow

    @State var itemToDelete: MenuItem?
    @State var isDeleting = false

    var body: some View {
        VStack {
            switch model.state {
            case .loading:
                ProgressView()
            case .ready:
                table
            case .error:
                Text("Error occured")
            }
        }
        .onAppear {
            model.fetch()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("New") {
                    openWindow(id: "new-pizza")
                }
            }
        }
        .navigationTitle("Menu")
        .alert("Are you sure you want to delete \(itemToDelete?.title ?? "this item")?",
               isPresented: $isDeleting,
               presenting: itemToDelete) { item in
            Button(role: .destructive) {
                model.delete(item: itemToDelete!)
            } label: {
                Text("Delete")
            }
        }
    }

    var table: some View {
        List {
            ForEach(model.items) { item in
                listRow(for: item)
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
    }

    func listRow(for item: MenuItem) -> some View {
        HStack {
            if let url = model.imageUrl(for: item) {
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

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        Container.shared.menuRepository.register { mockMenuRepository() }
        return MenuView()
    }
}
