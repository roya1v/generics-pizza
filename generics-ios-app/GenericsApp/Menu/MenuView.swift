//
//  MenuView.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 01/02/2023.
//

import SwiftUI
import Factory
import GenericsModels

struct MenuView: View {

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    @StateObject var model = MenuViewModel()

    @State var shownItem: MenuItem?

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                ScrollView {
                    switch model.state {
                    case .loading:
                        ProgressView()
                    case .ready:
                        menu
                    case .error:
                        Text("Something didn't work out :(")
                    }
                }
                .navigationTitle("Menu")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    model.fetch()
                }
                .sheet(item: $shownItem) { test in
                        MenuItemDetailView(item: test)
                }
            }

        }
    }

    var menu: some View {
        LazyVGrid(columns: columns) {
            ForEach(model.items) { item in
                MenuItemView(name: item.title,
                             description: item.description)
                .padding(.all, 4.0)
                .onTapGesture {
                    shownItem = item
                }
            }
        }
        .padding()
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        Container.menuRepository.register { MenuRepositoryMck() }
        return MenuView()
    }
}
