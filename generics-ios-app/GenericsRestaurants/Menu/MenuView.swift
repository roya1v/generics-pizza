//
//  MenuView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 13/03/2023.
//

import SwiftUI
import Factory

struct MenuView: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    @StateObject var model = MenuViewModel()

    @Environment(\.openWindow) var openWindow

    var body: some View {
        VStack {
            if model.isLoading {
                ProgressView()
            } else {
                table
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
        Table(model.items) {
            TableColumn("Title", value: \.title)
            TableColumn("Description", value: \.description)
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        Container.menuRepository.register { MenuRepositoryMck() }
        return MenuView()
    }
}
