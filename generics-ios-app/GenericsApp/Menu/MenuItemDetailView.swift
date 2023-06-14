//
//  MenuItemDetailView.swift
//  GenericsApp
//
//  Created by Mike S. on 21/03/2023.
//

import SwiftUI
import GenericsModels
import Factory

struct MenuItemDetailView: View {

    let item: MenuItem
    @Environment(\.presentationMode) var presentationMode
    @Injected(Container.orderRepository) var repository

    var imageURL: URL {
        URL(string: "http://localhost:8080/menu/\(item.id!)")!
    }

    var body: some View {
        VStack {
            HStack {
                Text(item.title)
                    .font(.largeTitle)
                Spacer()
            }
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    Image("pizzza_placeholder")
                        .resizable()
                        .scaledToFit()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure(_):
                    Image("pizzza_placeholder")
                        .resizable()
                        .scaledToFit()
                @unknown default:
                    fatalError()
                }
            }
            Divider()
            Text(item.description)
            Spacer()
            HStack {
                Spacer()
                Button {
                    repository.add(item: item)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Add to cart")
                        .padding(8.0)
                }
                .buttonStyle(.borderedProminent)
            }

        }
        .padding(24.0)
    }
}

struct MenuItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Color(.systemGray6)
            .sheet(isPresented: .constant(true)) {
                MenuItemDetailView(item: .init(id: nil,
                                               title: "Mocked pizza",
                                               description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.", price: 100))
            }

    }
}
