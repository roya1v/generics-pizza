//
//  MenuView.swift
//  GenericsApp
//
//  Created by Mike S. on 01/02/2023.
//

import SwiftUI
import Factory
import SharedModels
import GenericsCore

struct MenuView: View {

    @StateObject var model = MenuViewModel()

    var body: some View {
        NavigationView {
            Group {
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
        }
    }

    var menu: some View {
        List(model.items) { item in
            getMenuItem(for: item)
        }
    }

    func getMenuItem(for item: MenuItem) -> some View {
        HStack {
            AsyncImage(url: URL(string: "http://localhost:8080/menu/\(item.id!.uuidString)")!) { phase in
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
            VStack(alignment: .leading) {
                Text(item.title)
                Text(item.description)
                    .font(.genericsCaption)
            }
            Text(item.formattedPrice())
            Spacer()
            Button {
                model.add(item: item)
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        Container.shared.menuRepository.register { mockMenuRepository() }
        return MenuView()
    }
}
