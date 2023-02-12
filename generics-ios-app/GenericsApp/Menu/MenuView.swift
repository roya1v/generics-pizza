//
//  MenuView.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 01/02/2023.
//

import SwiftUI
import Factory

struct MenuView: View {

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    @StateObject var model = MenuViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(model.items) { item in
                        MenuItemView(name: item.title,
                                     description: item.description)
                    }
                }
                .padding()
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                model.fetch()
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        Container.menuRepository.register { MenuRepositoryMck() }
        return MenuView()
    }
}
