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
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.title2)
                Text(item.description)
                    .font(.caption)
            }
            Spacer()
            Text("\(item.price)")
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
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        Container.menuRepository.register { mockMenuRepository() }
        return MenuView()
    }
}
